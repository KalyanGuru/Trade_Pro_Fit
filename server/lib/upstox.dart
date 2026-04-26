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
  // SAVE TEMP PKCE VERIFIER
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
  // READ TOKEN
  // =====================================================

  Future<String> getAccessToken() async {
    final row = await (db.select(db.tokens)
      ..where((tbl) => tbl.id.equals(1)))
        .getSingleOrNull();

    if (row?.accessToken == null) {
      throw Exception(
        'No access token found. Open /auth/login first.',
      );
    }

    return row!.accessToken!;
  }

  // =====================================================
  // FETCH INSTRUMENTS
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchInstruments() async {
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

    if (response.statusCode >= 400) {
      throw Exception(
        'Instrument fetch failed: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    return [];
  }

  // =====================================================
  // FETCH OHLC
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchMinuteOHLC({
    required String instrumentKey,
    String interval = '1minute',
    int count = 500,
  }) async {
    final token = await getAccessToken();

    final uri = Uri.parse(
      '${Config.upstoxBase}/market/quotes/ohlc',
    ).replace(
      queryParameters: {
        'instrument_key': instrumentKey,
        'interval': interval,
        'count': '$count',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(
        'OHLC fetch failed: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }
}