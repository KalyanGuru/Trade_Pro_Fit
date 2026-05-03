// server/bin/server.dart

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:tread_pro_fit_server/config.dart';
import 'package:tread_pro_fit_server/db.dart';
import 'package:tread_pro_fit_server/upstox.dart';
import 'package:tread_pro_fit_server/ws.dart';

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
      jsonEncode({"status": "ok"}),
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

      return Response.found(loginUrl.toString());
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
      final verifier = await api.readTempVerifier() ?? '';

      await api.exchangeCodeForToken(code, verifier);

      return Response.ok(
        '''
<!DOCTYPE html>
<html>
<head>
<title>Connected</title>

<script>
setTimeout(() => {
  window.open('', '_self');
  window.close();
}, 5000);
</script>

<style>
body{
font-family:Arial;
text-align:center;
padding-top:100px;
}
</style>
</head>

<body>
<h2>Upstox Connected Successfully</h2>
<p>You can return to the Trade Pro Fit app tab now.</p>
</body>
</html>
''',
        headers: {'Content-Type': 'text/html'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Callback Error: $e',
      );
    }
  });

  // =========================================
  // AUTH STATUS
  // =========================================
  app.get('/auth/status', (Request req) async {
    final connected = await api.hasValidAccessToken();

    return Response.ok(
      jsonEncode({"connected": connected}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // LOGOUT / RESET AUTH
  // =========================================
  app.post('/auth/logout', (Request req) async {
    await api.clearTokens();

    return Response.ok(
      jsonEncode({"connected": false}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // SEARCH INSTRUMENTS
  // =========================================
  app.get('/instruments/search', (Request req) async {
    try {
      final q = (req.url.queryParameters['q'] ?? '').toLowerCase();
      // DEMO STATIC DATA
      final data = await api.fetchInstruments();

      final result = data.where((item) {
        final symbol = item["symbol"].toString().toLowerCase();

        final name = item["name"].toString().toLowerCase();

        return symbol.contains(q) || name.contains(q);
      }).toList();

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Search Failed: $e',
      );
    }
  });

  // =========================================
  // CLUSTERS
  // =========================================
  app.get('/clusters', (Request req) {
    return Response.ok(
      jsonEncode([
        {
          "cluster": "Banking",
          "strength": "High",
          "stocks": ["HDFCBANK", "ICICIBANK", "SBIN", "AXISBANK", "KOTAKBANK"]
        },
        {
          "cluster": "IT",
          "strength": "Medium",
          "stocks": ["TCS", "INFY", "WIPRO", "HCLTECH", "TECHM"]
        },
        {
          "cluster": "Energy",
          "strength": "High",
          "stocks": ["RELIANCE", "ONGC", "IOC", "BPCL", "GAIL"]
        },
        {
          "cluster": "Auto",
          "strength": "Medium",
          "stocks": ["TATAMOTORS", "MARUTI", "M&M", "BAJAJ-AUTO", "HEROMOTOCO"]
        },
        {
          "cluster": "Pharma",
          "strength": "Low",
          "stocks": ["SUNPHARMA", "DRREDDY", "CIPLA", "LUPIN", "AUROPHARMA"]
        }
      ]),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // PREDICTION
  // =========================================
  app.get('/predict/<key>', (Request req, String key) {
    return Response.ok(
      jsonEncode(
          {"key": key, "prediction": 1.85, "trend": "UP", "confidence": 87}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // LIVE PRICE
  // =========================================
  app.get('/live/<key>', (Request req, String key) async {
    final live = await api.fetchLivePrice(key);

    return Response.ok(
      jsonEncode(live),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // OHLC CANDLES
  // =========================================
  app.get('/candles/<key>', (Request req, String key) async {
    final candles = await api.fetchMinuteOHLC(
      instrumentKey: key,
    );

    return Response.ok(
      jsonEncode(candles),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // LIVE PRICE WEBSOCKET
  // =========================================
  final ltpWsHandler = ltpHandler(db);
  app.get('/ws/ltp', (Request request) => ltpWsHandler.call(request));

  // -----------------------------------------
  // PIPELINE
  // -----------------------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(app.call);

  // -----------------------------------------
  // START SERVER
  // -----------------------------------------
  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    Config.port,
  );

  stdout.writeln(
    'Backend Running on http://${server.address.host}:${server.port}',
  );
}