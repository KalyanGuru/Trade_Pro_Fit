import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tread_pro_fit_server/candle.dart';
import 'package:tread_pro_fit_server/config.dart';
import 'package:tread_pro_fit_server/db.dart';
import 'package:tread_pro_fit_server/kite.dart';
import 'package:tread_pro_fit_server/ws.dart';
import 'package:tread_pro_fit_server/features.dart';
import 'package:tread_pro_fit_server/ml.dart';

Future<void> main() async {
  // -----------------------------------------
  // INIT
  // -----------------------------------------
  Config.init();

  final db = AppDb();
  final api = KiteApi(db);

  final ws = WsService();
  final candle = CandleBuilder();
  final mlModel = NextHourModel();
  bool mlTrained = false;

  final app = Router();

  // Track connected Flutter WS clients for broadcasting ticks
  final List<WebSocketChannel> _clients = [];

  // =========================================
  // ROOT
  // =========================================
  app.get('/', (_) => Response.ok('Backend Running'));

  // =========================================
  // HEALTH
  // =========================================
  app.get('/health', (_) => Response.ok(
    jsonEncode({"status": "ok"}),
    headers: {'Content-Type': 'application/json'},
  ));

  // =========================================
  // AUTH LOGIN — Kite Connect
  // =========================================
  app.get('/auth/login', (req) {
    // Redirect user to Kite login page
    return Response.found(api.loginUrl.toString());
  });

  // =========================================
  // AUTH CALLBACK — Kite Connect
  // =========================================
  app.get('/auth/callback', (req) async {
    final requestToken = req.url.queryParameters['request_token'];
    final status = req.url.queryParameters['status'];

    if (requestToken == null || status != 'success') {
      return Response.badRequest(
        body: 'Login failed or missing request_token',
      );
    }

    try {
      await api.exchangeToken(requestToken);
      return Response.ok(
        '<html><body style="font-family:sans-serif;text-align:center;padding:60px;">'
        '<h1 style="color:green;">✅ Kite Connected Successfully</h1>'
        '<p>You can close this tab and return to the app.</p>'
        '</body></html>',
        headers: {'Content-Type': 'text/html'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Token exchange failed: $e',
      );
    }
  });

  // =========================================
  // AUTH STATUS
  // =========================================
  app.get('/auth/status', (req) async {
    final ok = await api.hasValidAccessToken();

    return Response.ok(
      jsonEncode({"connected": ok}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // LOGOUT
  // =========================================
  app.post('/auth/logout', (req) async {
    await api.clearTokens();

    return Response.ok(jsonEncode({"connected": false}));
  });

  // =========================================
  // SEARCH (STATIC DEMO DATA)
  // =========================================
  app.get('/instruments/search', (req) {
    final q = (req.url.queryParameters['q'] ?? '').toUpperCase();

    final data = [
      {
        "instrument_key": "NSE_EQ|RELIANCE",
        "instrument_token": 738561,
        "symbol": "RELIANCE",
        "name": "Reliance Industries"
      },
      {
        "instrument_key": "NSE_EQ|INFY",
        "instrument_token": 408065,
        "symbol": "INFY",
        "name": "Infosys"
      },
      {
        "instrument_key": "NSE_EQ|TCS",
        "instrument_token": 2953217,
        "symbol": "TCS",
        "name": "Tata Consultancy Services"
      },
      {
        "instrument_key": "NSE_EQ|HDFCBANK",
        "instrument_token": 341249,
        "symbol": "HDFCBANK",
        "name": "HDFC Bank"
      },
      {
        "instrument_key": "NSE_EQ|SBIN",
        "instrument_token": 779521,
        "symbol": "SBIN",
        "name": "State Bank of India"
      },
      {
        "instrument_key": "NSE_EQ|ICICIBANK",
        "instrument_token": 1270529,
        "symbol": "ICICIBANK",
        "name": "ICICI Bank"
      },
    ];

    final result = data
        .where((e) =>
            e["symbol"]!.toString().contains(q) ||
            e["name"]!.toString().toUpperCase().contains(q))
        .toList();

    return Response.ok(jsonEncode(result),
        headers: {'Content-Type': 'application/json'});
  });

  // =========================================
  // START WEBSOCKET STREAM (KITE)
  // =========================================

  // Map of instrument_key -> instrument_token (from search data)
  final Map<String, int> _keyToToken = {
    'NSE_EQ|RELIANCE': 738561,
    'NSE_EQ|INFY': 408065,
    'NSE_EQ|TCS': 2953217,
    'NSE_EQ|HDFCBANK': 341249,
    'NSE_EQ|SBIN': 779521,
    'NSE_EQ|ICICIBANK': 1270529,
  };
  final Map<int, String> _tokenToKey = {
    738561: 'NSE_EQ|RELIANCE',
    408065: 'NSE_EQ|INFY',
    2953217: 'NSE_EQ|TCS',
    341249: 'NSE_EQ|HDFCBANK',
    779521: 'NSE_EQ|SBIN',
    1270529: 'NSE_EQ|ICICIBANK',
  };

  app.get('/start/<key>', (Request req, String key) async {
    try {
      final cleanKey = Uri.decodeComponent(key);
      final token = _keyToToken[cleanKey];

      if (token == null) {
        return Response.badRequest(body: 'Unknown instrument: $cleanKey');
      }

      final wsUrl = await api.getWsUrl();

      ws.connect(
        wsUrl: wsUrl,
        tokens: [token],
        onTick: (tick) {
          // Map integer token back to our string key
          final rawToken = tick['instrument_key'];
          if (rawToken is String) {
            final intToken = int.tryParse(rawToken);
            if (intToken != null && _tokenToKey.containsKey(intToken)) {
              tick['instrument_key'] = _tokenToKey[intToken]!;
            }
          }

          candle.addTick(tick);
          print("PRICE: ${tick['instrument_key']} -> ${tick['ltp']}");

          // Broadcast to connected Flutter clients
          final msg = jsonEncode({'ticks': [tick]});
          final disconnected = <WebSocketChannel>[];
          for (final client in _clients) {
            try {
              client.sink.add(msg);
            } catch (_) {
              disconnected.add(client);
            }
          }
          for (final c in disconnected) {
            _clients.remove(c);
          }
        },
      );

      return Response.ok("Stream started for $cleanKey (token=$token)");
    } catch (e) {
      return Response.internalServerError(body: "$e");
    }
  });

  // =========================================
  // GET LIVE CANDLES
  // =========================================
  app.get('/candles/<key>', (req, String key) {
    final cleanKey = Uri.decodeComponent(key);
    final data = candle.get(cleanKey);

    // Return as list of maps with 'close' field for compatibility
    final candleData = data.map((price) => {'close': price}).toList();

    return Response.ok(
      jsonEncode(candleData),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // =========================================
  // CLUSTERS (STATIC DEMO)
  // =========================================
  app.get('/clusters', (_) => Response.ok(
    jsonEncode([
      {
        "cluster": "Momentum Leaders",
        "strength": "High",
        "cluster_type": "profitable",
        "stocks": ["RELIANCE", "HDFCBANK", "SBIN"]
      },
      {
        "cluster": "IT Sector",
        "strength": "Medium",
        "cluster_type": "neutral",
        "stocks": ["TCS", "INFY"]
      },
      {
        "cluster": "Banking Volatile",
        "strength": "Low",
        "cluster_type": "neutral",
        "stocks": ["ICICIBANK", "AXISBANK"]
      }
    ]),
    headers: {'Content-Type': 'application/json'},
  ));

  // =========================================
  // PREDICTION — REAL ML (LinearRegressor)
  // =========================================
  app.get('/predict/<key>', (req, String key) {
    final cleanKey = Uri.decodeComponent(key);
    final bars = candle.getBars(cleanKey);
    final currentLtp = candle.getCurrentLtp(cleanKey);

    double prediction = 0.0;
    String trend = 'SIDEWAYS';
    int confidence = 50;
    String clusterType = 'neutral';
    bool mlUsed = false;

    // --- Attempt ML prediction if we have enough bars ---
    if (bars.length >= 15 && currentLtp != null) {
      try {
        final features = computeFeatures(bars);

        // Build training data from feature columns
        // Feature vector: [r5m, r15m, d20, d50, ema20_slope, rsi14, atr14, vol15, d_vwap, vol_surge]
        final featureKeys = [
          'r5m', 'r15m', 'd20', 'd50', 'ema20_slope',
          'rsi14', 'atr14', 'vol15', 'd_vwap', 'vol_surge',
        ];
        final targetKey = 'target_60';

        // Find minimum feature length across all columns
        int minLen = features.cols[targetKey]?.length ?? 0;
        for (final fk in featureKeys) {
          final col = features.cols[fk];
          if (col == null || col.isEmpty) {
            minLen = 0;
            break;
          }
          if (col.length < minLen) minLen = col.length;
        }

        if (minLen >= 20) {
          // Build X and y from the tail of the feature columns
          final X = <List<double>>[];
          final y = <double>[];

          final targetCol = features.cols[targetKey]!;
          for (int i = 0; i < minLen; i++) {
            final row = <double>[];
            bool valid = true;
            for (final fk in featureKeys) {
              final val = features.cols[fk]![i];
              if (val.isNaN || val.isInfinite) {
                valid = false;
                break;
              }
              row.add(val);
            }
            final target = targetCol[i];
            if (!valid || target.isNaN || target.isInfinite) continue;

            X.add(row);
            y.add(target);
          }

          if (X.length >= 15) {
            // Train model on available data
            try {
              mlModel.fit(X, y);
              mlTrained = true;

              // Predict using latest features
              final latestRow = X.last;
              prediction = mlModel.predict(latestRow) * 100; // convert to %
              mlUsed = true;

              // Record prediction for MAE/RMSE tracking
              candle.recordPrediction(cleanKey, prediction / 100, currentLtp);

              print('🤖 ML Prediction for $cleanKey: ${prediction.toStringAsFixed(4)}%');
            } catch (e) {
              print('⚠️ ML training failed: $e');
            }
          }
        }
      } catch (e) {
        print('⚠️ Feature computation failed: $e');
      }
    }

    // Fallback: use momentum if ML not available yet
    if (!mlUsed) {
      final prices = candle.get(cleanKey);
      if (prices.length >= 5) {
        final recent = prices.sublist(prices.length - 5);
        final first = recent.first;
        final last = recent.last;
        prediction = ((last - first) / first) * 100;

        if (currentLtp != null) {
          candle.recordPrediction(cleanKey, prediction / 100, currentLtp);
        }
      }
    }

    // Determine trend and confidence
    if (prediction > 0.1) {
      trend = 'UP';
      confidence = min(99, 60 + (prediction.abs() * 8).toInt());
    } else if (prediction < -0.1) {
      trend = 'DOWN';
      confidence = min(99, 60 + (prediction.abs() * 8).toInt());
    } else {
      trend = 'SIDEWAYS';
      confidence = 40 + (20 - prediction.abs() * 10).clamp(0, 20).toInt();
    }

    // Cluster type from recent volatility
    final prices = candle.get(cleanKey);
    if (prices.length >= 5) {
      final recent = prices.sublist(prices.length - 5);
      final maxP = recent.reduce((a, b) => a > b ? a : b);
      final minP = recent.reduce((a, b) => a < b ? a : b);
      final volatility = (maxP - minP) / minP * 100;
      if (volatility > 1.5 && prediction > 0) {
        clusterType = 'profitable';
      } else if (volatility > 1.5) {
        clusterType = 'volatile';
      }
    }

    return Response.ok(jsonEncode({
      "key": cleanKey,
      "prediction": double.parse(prediction.toStringAsFixed(4)),
      "trend": trend,
      "confidence": confidence.clamp(0, 99),
      "cluster_type": clusterType,
      "ml_model_active": mlUsed,
      "bars_available": bars.length,
    }),
    headers: {'Content-Type': 'application/json'});
  });

  // =========================================
  // METRICS — REAL PREDICTION HISTORY + MAE + RMSE
  // =========================================
  app.get('/metrics/<key>', (req, String key) {
    final cleanKey = Uri.decodeComponent(key);

    final history = candle.getPredictionHistory(cleanKey);
    final rollingMAE = candle.getRollingMAE(cleanKey);
    final rollingRMSE = candle.getRollingRMSE(cleanKey);
    final currentMAE = candle.getCurrentMAE(cleanKey);
    final currentRMSE = candle.getCurrentRMSE(cleanKey);

    return Response.ok(jsonEncode({
      "key": cleanKey,
      "predictions": history.map((r) => r.toJson()).toList(),
      "mae": currentMAE ?? 0.0,
      "rmse": currentRMSE ?? 0.0,
      "mae_history": rollingMAE.map((v) => double.parse(v.toStringAsFixed(4))).toList(),
      "rmse_history": rollingRMSE.map((v) => double.parse(v.toStringAsFixed(4))).toList(),
      "data_points": history.length,
      "ml_trained": mlTrained,
    }),
    headers: {'Content-Type': 'application/json'});
  });

  // =========================================
  // WEBSOCKET ENDPOINT FOR FLUTTER CLIENTS
  // =========================================
  // This is the /ws/ltp endpoint that the Flutter WsClient connects to.
  // It broadcasts ticks received from Kite to all connected Flutter clients.

  final wsHandler = webSocketHandler((WebSocketChannel webSocket) {
    print('🔌 Flutter client connected');
    _clients.add(webSocket);

    webSocket.stream.listen(
      (message) {
        // Handle subscription messages from Flutter
        try {
          final data = jsonDecode(message as String);
          if (data['subscribe'] != null) {
            print('📡 Client subscribed: ${data['subscribe']}');
          }
        } catch (e) {
          print('⚠️ Client message parse error: $e');
        }
      },
      onDone: () {
        print('🔌 Flutter client disconnected');
        _clients.remove(webSocket);
      },
      onError: (e) {
        print('❌ Client error: $e');
        _clients.remove(webSocket);
      },
    );
  });

  // -----------------------------------------
  // PIPELINE
  // -----------------------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler((Request request) {
    // Route WebSocket requests to the WS handler
    if (request.url.path == 'ws/ltp') {
      return wsHandler(request);
    }
    return app(request);
  });

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    Config.port,
  );

  print('🚀 Server running on http://localhost:${server.port}');
}