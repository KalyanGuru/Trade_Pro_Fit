// server/lib/upstox.dart

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as d;

import 'config.dart';
import 'db.dart';

class UpstoxApi {
  final AppDb db;

  UpstoxApi(this.db);

  // =====================================================
  // PKCE GENERATOR
  // =====================================================

  Future<Map<String, String>> pkce() async {
    final randomBytes =
    List<int>.generate(40, (_) => Random.secure().nextInt(256));

    final verifier =
    base64UrlEncode(randomBytes).replaceAll('=', '');

    final digest =
    sha256.convert(utf8.encode(verifier));

    final challenge =
    base64UrlEncode(digest.bytes).replaceAll('=', '');

    return {
      'verifier': verifier,
      'challenge': challenge,
    };
  }

  // =====================================================
  // LOGIN URL
  // =====================================================

  Uri authUrl(String challenge) {
    return Uri.parse(
      'https://api.upstox.com/v2/login/authorization/dialog'
          '?response_type=code'
          '&client_id=${Config.upstoxClientId}'
          '&redirect_uri=${Uri.encodeComponent(Config.redirectUri)}'
          '&code_challenge=$challenge'
          '&code_challenge_method=S256',
    );
  }

  // =====================================================
  // SAVE TEMP VERIFIER
  // =====================================================

  Future<void> saveTempVerifier(String verifier) async {
    await db.into(db.tokens).insertOnConflictUpdate(
      TokensCompanion.insert(
        id: const d.Value(9999),
        accessToken: d.Value(verifier),
      ),
    );
  }

  Future<String?> readTempVerifier() async {
    final row = await (db.select(db.tokens)
      ..where((tbl) => tbl.id.equals(9999)))
        .getSingleOrNull();

    return row?.accessToken;
  }

  // =====================================================
  // TOKEN EXCHANGE
  // =====================================================

  Future<void> exchangeCodeForToken(
      String code,
      String verifier,
      ) async {
    final uri = Uri.parse(
      '${Config.upstoxBase}/login/authorization/token',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': Config.upstoxClientId,
        'client_secret': Config.upstoxClientSecret,
        'redirect_uri': Config.redirectUri,
        'code_verifier': verifier,
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(
        'Token exchange failed: '
            '${response.statusCode} ${response.body}',
      );
    }

    final json =
    jsonDecode(response.body) as Map<String, dynamic>;

    final expiresIn =
        (json['expires_in'] as num?)?.toInt() ?? 3600;

    final expiry =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 +
            expiresIn;

    await db.into(db.tokens).insertOnConflictUpdate(
      TokensCompanion.insert(
        id: const d.Value(1),
        accessToken:
        d.Value(json['access_token'] as String?),
        refreshToken:
        d.Value(json['refresh_token'] as String?),
        expiresAt: d.Value(expiry),
      ),
    );
  }

  // =====================================================
  // GET TOKEN
  // =====================================================

  Future<String> getAccessToken() async {
    final row = await (db.select(db.tokens)
      ..where((tbl) => tbl.id.equals(1)))
        .getSingleOrNull();

    if (row?.accessToken == null) {
      throw Exception(
        'No access token found. Login first.',
      );
    }

    return row!.accessToken!;
  }

  // =====================================================
  // FETCH INSTRUMENTS (REAL + FALLBACK)
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchInstruments() async {
    try {
      final token = await getAccessToken();

      final uri = Uri.parse(
        '${Config.upstoxBase}/market/instruments',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }

        if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(
            data['data'],
          );
        }
      }
    } catch (_) {}

    // FALLBACK STATIC DATA
    return [
      {
        "key": "NSE_EQ|RELIANCE",
        "symbol": "RELIANCE",
        "name": "Reliance Industries"
      },
      {
        "key": "NSE_EQ|TCS",
        "symbol": "TCS",
        "name": "Tata Consultancy Services"
      },
      {
        "key": "NSE_EQ|INFY",
        "symbol": "INFY",
        "name": "Infosys"
      },
      {
        "key": "NSE_EQ|HDFCBANK",
        "symbol": "HDFCBANK",
        "name": "HDFC Bank"
      },
      {
        "key": "NSE_EQ|ICICIBANK",
        "symbol": "ICICIBANK",
        "name": "ICICI Bank"
      },
      {
        "key": "NSE_EQ|SBIN",
        "symbol": "SBIN",
        "name": "State Bank of India"
      },
      {
        "key": "NSE_EQ|ITC",
        "symbol": "ITC",
        "name": "ITC Ltd"
      },
      {
        "key": "NSE_EQ|LT",
        "symbol": "LT",
        "name": "Larsen & Toubro"
      }
    ];
  }

  // =====================================================
  // FETCH LIVE PRICE
  // =====================================================

  Future<Map<String, dynamic>> fetchLivePrice(
      String instrumentKey,
      ) async {
    final random = Random();

    return {
      "key": instrumentKey,
      "ltp": 1000 + random.nextInt(500),
      "change": (random.nextDouble() * 10),
      "changePercent": (random.nextDouble() * 2),
    };
  }

  // =====================================================
  // FETCH OHLC
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchMinuteOHLC({
    required String instrumentKey,
    String interval = '1minute',
    int count = 50,
  }) async {
    final random = Random();

    return List.generate(count, (i) {
      final open = 1000 + random.nextInt(100);
      final close = open + random.nextInt(20) - 10;
      final high = open + random.nextInt(15);
      final low = open - random.nextInt(15);

      return {
        "time": DateTime.now()
            .subtract(Duration(minutes: count - i))
            .toIso8601String(),
        "open": open.toDouble(),
        "high": high.toDouble(),
        "low": low.toDouble(),
        "close": close.toDouble(),
        "volume": 10000 + random.nextInt(5000),
      };
    });
  }
}