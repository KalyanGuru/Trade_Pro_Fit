// server/bin/server.dart

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../lib/config.dart';
import '../lib/db.dart';
import '../lib/upstox.dart';

Future<void> main() async {
  // -----------------------------------------
  // LOAD CONFIG
  // -----------------------------------------
  Config.init();

  // -----------------------------------------
  // DATABASE + API
  // -----------------------------------------
  final db = AppDb();
  final api = UpstoxApi(db);

  // -----------------------------------------
  // ROUTER
  // -----------------------------------------
  final app = Router();

  // =========================================
  // ROOT
  // =========================================
  app.get('/', (Request req) {
    return Response.ok(
      'Tread Pro Fit Backend Running',
      headers: {'Content-Type': 'text/plain'},
    );
  });

  // =========================================
  // HEALTH
  // =========================================
  app.get('/health', (Request req) {
    return Response.ok(
      '{"status":"ok"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // LOGIN ROUTE
  // =========================================
  app.get('/auth/login', (Request req) async {
    try {
      final pkce = await api.pkce();

      final verifier = pkce['verifier']!;
      final challenge = pkce['challenge']!;

      await api.saveTempVerifier(verifier);

      final loginUrl = api.authUrl(challenge);

      return Response.found(
        loginUrl.toString(),
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Login Error: $e',
      );
    }
  });

  // =========================================
  // CALLBACK ROUTE
  // =========================================
  app.get('/auth/callback', (Request req) async {
    final code = req.url.queryParameters['code'];

    if (code == null || code.isEmpty) {
      return Response.badRequest(
        body: 'Authorization code missing',
      );
    }

    try {
      final verifier =
          await api.readTempVerifier() ?? '';

      await api.exchangeCodeForToken(
        code,
        verifier,
      );

      return Response.ok(
        '''
<html>
<head>
<title>Connected</title>
</head>
<body>
<h2>Upstox Connected Successfully</h2>
<p>You can return to the app.</p>
</body>
</html>
''',
        headers: {
          'Content-Type': 'text/html',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Callback Error: $e',
      );
    }
  });

  // =========================================
  // SEARCH INSTRUMENTS
  // =========================================
  app.get('/instruments/search', (Request req) async {
    try {
      final q =
          req.url.queryParameters['q'] ?? '';

      final all =
      await api.fetchInstruments();

      final result = all.where((item) {
        final symbol =
        (item['symbol'] ?? '')
            .toString()
            .toLowerCase();

        return symbol.contains(
          q.toLowerCase(),
        );
      }).take(50).toList();

      return Response.ok(
        result.toString(),
        headers: {
          'Content-Type':
          'application/json'
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body:
        'Search Failed: $e',
      );
    }
  });

  // =========================================
  // CLUSTERS
  // =========================================
  app.get('/clusters', (Request req) {
    return Response.ok(
      '[]',
      headers: {
        'Content-Type':
        'application/json'
      },
    );
  });

  // =========================================
  // PREDICTION
  // =========================================
  app.get('/predict/<key>',
          (Request req, String key) {
        return Response.ok(
          '''
{
 "key":"$key",
 "prediction":1.85,
 "trend":"UP"
}
''',
          headers: {
            'Content-Type':
            'application/json'
          },
        );
      });

  // =========================================
  // LIVE
  // =========================================
  app.get('/live/<key>',
          (Request req, String key) {
        return Response.ok(
          '''
{
 "key":"$key",
 "ltp":1250.45
}
''',
          headers: {
            'Content-Type':
            'application/json'
          },
        );
      });

  // -----------------------------------------
  // PIPELINE
  // -----------------------------------------
  final handler =
  const Pipeline()
      .addMiddleware(
    logRequests(),
  )
      .addMiddleware(
    corsHeaders(),
  )
      .addHandler(app);

  // -----------------------------------------
  // START SERVER
  // -----------------------------------------
  final server =
  await io.serve(
    handler,
    InternetAddress.anyIPv4,
    Config.port,
  );

  print(
    'Backend Running on http://${server.address.host}:${server.port}',
  );
}