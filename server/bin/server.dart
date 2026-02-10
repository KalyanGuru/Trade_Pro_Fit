// server/bin/server.dart
//
// Clean, corrected server entrypoint for the Dart backend.
// - Uses Drift AppDb from server/lib/db.dart
// - Uses Config from server/lib/config.dart (which loads .env)
// - Uses UpstoxApi from server/lib/upstox.dart (pkce(), saveTempVerifier(), exchangeCodeForToken(), fetchInstruments(), fetchMinuteOHLC())
// - Provides endpoints: /auth/login, /auth/callback, /instruments/search, /features/prediction, /clusters/latest, /ws/ltp
//
// Replace your old file with this exact content.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' show webSocketHandler;
import 'package:drift/drift.dart' as d;

import '../lib/config.dart';
import '../lib/db.dart';
import '../lib/upstox.dart';

Future<void> main() async {
  // Config reads env variables on import (see server/lib/config.dart)
  final port = Config.port;

  // Initialize DB and API adapter
  final db = AppDb();
  final upstox = UpstoxApi(db);

  final router = Router();

  // ---------- AUTH: start login (PKCE) ----------
  router.get('/auth/login', (Request req) async {
    try {
      final pk = await upstox.pkce(); // returns {'verifier','challenge'}
      final verifier = pk['verifier']!;
      final challenge = pk['challenge']!;
      await upstox.saveTempVerifier(verifier);

      final url = upstox.authUrl(challenge).toString();
      // Redirect user to Upstox authorization URL
      return Response.found(url);
    } catch (e, st) {
      stderr.writeln('Error in /auth/login: $e\n$st');
      return Response.internalServerError(body: 'Auth start failed: $e');
    }
  });

  // ---------- AUTH: callback ----------
  router.get('/auth/callback', (Request req) async {
    try {
      final code = req.requestedUri.queryParameters['code'];
      if (code == null) {
        return Response(400, body: 'Missing code parameter');
      }

      final verifier = await upstox.readTempVerifier();
      if (verifier == null) {
        return Response(400, body: 'Missing PKCE verifier in server state');
      }

      await upstox.exchangeCodeForToken(code, verifier);
      return Response.ok(jsonEncode({'status': 'ok'}), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('Error in /auth/callback: $e\n$st');
      return Response.internalServerError(body: 'Token exchange failed: $e');
    }
  });

  // ---------- Instruments: search (cache-first) ----------
  router.get('/instruments/search', (Request req) async {
    final qRaw = req.requestedUri.queryParameters['q'] ?? '';
    final q = qRaw.trim();
    if (q.isEmpty) {
      return Response.ok(jsonEncode({'data': []}), headers: {'content-type': 'application/json'});
    }

    try {
      // 1) Try local cache
      final rows = await (db.select(db.instruments)
        ..where((t) =>
        t.symbol.like('%${q.toUpperCase()}%') | t.name.like('%$q%'))
        ..limit(50))
          .get();

      if (rows.isNotEmpty) {
        final data = rows
            .map((r) => {
          'instrument_key': r.instrumentKey,
          'symbol': r.symbol,
          'name': r.name
        })
            .toList();
        return Response.ok(jsonEncode({'from_cache': true, 'data': data}),
            headers: {'content-type': 'application/json'});
      }

      // 2) Fetch from Upstox and fill cache (use batch callback)
      final list = await upstox.fetchInstruments();
      await db.batch((batch) {
        for (final it in list) {
          final k = (it['instrument_key'] ?? it['instrument_token'] ?? it['key'] ?? '').toString();
          final s = (it['tradingsymbol'] ?? it['symbol'] ?? '').toString();
          final n = (it['name'] ?? s).toString();
          if (k.isNotEmpty && s.isNotEmpty) {
            batch.insert(
              db.instruments,
              InstrumentsCompanion.insert(
                instrumentKey: k,
                symbol: s.toUpperCase(),
                // name is nullable, so wrap with d.Value
                name: d.Value(n.isEmpty ? null : n),
              ),
              mode: d.InsertMode.insertOrIgnore,
            );
          }
        }
      });

      // 3) Query cache again
      final rows2 = await (db.select(db.instruments)
        ..where((t) =>
        t.symbol.like('%${q.toUpperCase()}%') | t.name.like('%$q%'))
        ..limit(50))
          .get();

      final data2 = rows2
          .map((r) => {
        'instrument_key': r.instrumentKey,
        'symbol': r.symbol,
        'name': r.name
      })
          .toList();

      return Response.ok(jsonEncode({'from_cache': false, 'data': data2}),
          headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('Error in /instruments/search: $e\n$st');
      return Response.internalServerError(body: 'Error fetching instruments: $e');
    }
  });

  // ---------- Prediction endpoint (returns latest prediction row if exists) ----------
  router.get('/features/prediction', (Request req) async {
    final k = req.requestedUri.queryParameters['instrument_key'];
    if (k == null || k.isEmpty) {
      return Response(400, body: 'instrument_key required');
    }

    try {
      final q = (db.select(db.predictions)
        ..where((t) => t.instrumentKey.equals(k))
        ..orderBy([(t) => d.OrderingTerm(expression: t.ts, mode: d.OrderingMode.desc)])
        ..limit(1));
      final row = await q.getSingleOrNull();
      if (row == null) {
        return Response.ok(jsonEncode({'ts': null, 'ret_pred': 0.0, 'curve': []}),
            headers: {'content-type': 'application/json'});
      }

      // Predictions table columns: instrumentKey, ts, horizon, retPred, curve
      final curve =
      (row.curve == null || row.curve!.isEmpty) ? [] : jsonDecode(row.curve!);
      return Response.ok(
          jsonEncode({'ts': row.ts, 'ret_pred': row.retPred, 'curve': curve}),
          headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('Error in /features/prediction: $e\n$st');
      return Response.internalServerError(body: 'Error fetching prediction: $e');
    }
  });

  // ---------- Clusters: latest (simple listing) ----------
  router.get('/clusters/latest', (Request req) async {
    try {
      // Return recent clusters (limit to 500)
      final rows = await (db.select(db.clusters)
        ..orderBy([(t) => d.OrderingTerm(expression: t.ts, mode: d.OrderingMode.desc)])
        ..limit(500))
          .get();

      final data = rows
          .map((r) => {
        'instrument_key': r.instrumentKey,
        'label': r.label,
        'cluster': r.cluster,
        'ts': r.ts
      })
          .toList();

      return Response.ok(jsonEncode({'data': data}), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('Error in /clusters/latest: $e\n$st');
      return Response.internalServerError(body: 'Error fetching clusters: $e');
    }
  });

  // ---------- Simple WebSocket LTP feed (echo / demo) ----------
  router.get('/ws/ltp', webSocketHandler((webSocket) {
    // Simple echo: accept subscription messages that contain {"subscribe":["instrument_key", ...]}
    webSocket.stream.listen((message) {
      try {
        final m = message is String ? jsonDecode(message) : message;
        if (m is Map && m['subscribe'] is List) {
          // Acknowledge
          webSocket.sink.add(jsonEncode({'ok': true, 'subscribed': m['subscribe']}));
        } else {
          // echo back
          webSocket.sink.add(jsonEncode({'echo': m}));
        }
      } catch (e) {
        webSocket.sink.add(jsonEncode({'error': 'invalid message', 'raw': message.toString()}));
      }
    }, onDone: () {
      // connection closed
    });
  }));

  // ---------- Build pipeline & serve ----------
  final handler =
  const Pipeline().addMiddleware(logRequests()).addMiddleware(corsHeaders()).addHandler(router);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('Dart backend running on http://localhost:${server.port}');
}