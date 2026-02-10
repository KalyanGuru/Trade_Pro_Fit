// server/lib/upstox.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'db.dart';
import 'package:drift/drift.dart' as d;

class UpstoxApi {
  final AppDb db;
  UpstoxApi(this.db);

  // ----- PKCE helpers -----
  /// returns map {verifier, challenge}
  Future<Map<String, String>> pkce() async {
    final rnd = List<int>.generate(40, (_) => Random.secure().nextInt(256));
    final verifier = base64UrlEncode(rnd).replaceAll('=', '');
    final digest = sha256.convert(utf8.encode(verifier));
    final challenge = base64UrlEncode(digest.bytes).replaceAll('=', '');
    return {'verifier': verifier, 'challenge': challenge};
  }

  Uri authUrl(String challenge) {
    final base = Config.upstoxBase;
    final client = Uri.encodeQueryComponent(Config.upstoxClientId);
    final redirect = Uri.encodeQueryComponent(Config.redirectUri);
    return Uri.parse(
        f'https://api.upstox.com/v2/login/authorization/dialog?response_type=code&client_id=4f5ca23d-4e5d-462f-9cad-d5ba688aa554&redirect_uri=http://localhost:8080/auth/callback);
  }

  Future<void> saveTempVerifier(String verifier) async {
    await db.into(db.tokens).insertOnConflictUpdate(
      TokensCompanion.insert(id: d.Value(9999), accessToken: d.Value(verifier)),
    );
  }

  Future<String?> readTempVerifier() async {
    final t = await (db.select(db.tokens)..where((tbl) => tbl.id.equals(9999))).getSingleOrNull();
    return t?.accessToken;
  }

  // ---- Token exchange ----
  Future<void> exchangeCodeForToken(String code, String verifier) async {
    final uri = Uri.parse('${Config.upstoxBase}/login/authorization/token');
    final resp = await http.post(uri, body: {
      'grant_type': 'authorization_code',
      'code': code,
      'client_id': Config.upstoxClientId,
      'redirect_uri': Config.redirectUri,
      'code_verifier': verifier,
    });
    if (resp.statusCode >= 400) {
      throw Exception('Token exchange failed: ${resp.statusCode} ${resp.body}');
    }
    final tok = jsonDecode(resp.body) as Map<String, dynamic>;
    final expiresIn = (tok['expires_in'] as num?)?.toInt() ?? 3600;
    final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn;
    await db.into(db.tokens).insertOnConflictUpdate(
      TokensCompanion.insert(
        id: d.Value(1),
        accessToken: d.Value(tok['access_token'] as String?),
        refreshToken: d.Value(tok['refresh_token'] as String?),
        expiresAt: d.Value(exp),
      ),
    );
  }

  Future<String> getAccessToken() async {
    final t = await (db.select(db.tokens)..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
    if (t?.accessToken == null) {
      throw Exception('No access token; open /auth/login first.');
    }
    return t!.accessToken!;
  }

  // ---- Market endpoints (may need path adjustments per your account) ----
  Future<List<Map<String, dynamic>>> fetchInstruments() async {
    final tok = await getAccessToken();
    final uri = Uri.parse('${Config.upstoxBase}/market/instruments');
    final r = await http.get(uri, headers: {'Authorization': 'Bearer $tok'});
    if (r.statusCode >= 400) throw Exception('Instruments failed: ${r.statusCode} ${r.body}');
    final data = jsonDecode(r.body);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchMinuteOHLC({
    required String instrumentKey,
    String interval = '1minute',
    int count = 500,
  }) async {
    final tok = await getAccessToken();
    final uri = Uri.parse('${Config.upstoxBase}/market/quotes/ohlc').replace(queryParameters: {
      'instrument_key': instrumentKey,
      'interval': interval,
      'count': '$count',
    });
    final r = await http.get(uri, headers: {'Authorization': 'Bearer $tok'});
    if (r.statusCode >= 400) throw Exception('OHLC failed: ${r.statusCode} ${r.body}');
    final data = jsonDecode(r.body);
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}