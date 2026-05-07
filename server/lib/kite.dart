// server/lib/kite.dart
//
// Kite Connect API integration.
// Handles OAuth login flow, token exchange, and access token management.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as d;

import 'config.dart';
import 'db.dart';

class KiteApi {
  final AppDb db;

  KiteApi(this.db);

  // =====================================================
  // KITE LOGIN URL
  // =====================================================
  /// Generates the Kite Connect login URL.
  /// User is redirected here to authenticate via Kite's login page.
  Uri get loginUrl => Uri.parse('https://kite.trade/connect/login''?v=3''&api_key=${Config.kiteApiKey}',
  );

  // =====================================================
  // TOKEN EXCHANGE
  // =====================================================
  /// Exchange the request_token (received at callback) for an access_token.
  /// Kite uses checksum = sha256(api_key + request_token + api_secret).
  Future<void> exchangeToken(String requestToken) async {
    final raw = '${Config.kiteApiKey}$requestToken${Config.kiteApiSecret}';
    final checksum = sha256.convert(utf8.encode(raw)).toString();

    final uri = Uri.parse('https://api.kite.trade/session/token');

    final res = await http.post(
      uri,
      headers: {
        'X-Kite-Version': '3',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'api_key': Config.kiteApiKey,
        'request_token': requestToken,
        'checksum': checksum,
      },
    );

    if (res.statusCode != 200) {
      print('Kite token exchange failed: ${res.body}');
      throw Exception('Token exchange failed (${res.statusCode})');
    }

    final json = jsonDecode(res.body);
    final data = json['data'];

    if (data == null || data['access_token'] == null) {
      throw Exception('No access_token in response');
    }

    await db.into(db.tokens).insertOnConflictUpdate(
      TokensCompanion.insert(
        id: const d.Value(1),
        accessToken: d.Value(data['access_token']),
        refreshToken: d.Value(data['refresh_token']),
      ),
    );

    print('KITE TOKEN SAVED');
  }

  // =====================================================
  // GET ACCESS TOKEN
  // =====================================================
  Future<String> getAccessToken() async {
    final row = await (db.select(db.tokens)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (row?.accessToken == null || row!.accessToken!.isEmpty) {
      throw Exception('Not logged in to Kite');
    }

    return row.accessToken!;
  }

  // =====================================================
  // BUILD WS URL
  // =====================================================
  /// Returns the Kite WebSocket URL with auth params embedded.
  Future<String> getWsUrl() async {
    final token = await getAccessToken();
    return 'wss://ws.kite.trade'
        '?api_key=${Config.kiteApiKey}'
        '&access_token=$token';
  }

  // =====================================================
  // TOKEN CHECK
  // =====================================================
  Future<bool> hasValidAccessToken() async {
    try {
      final token = await getAccessToken();
      return token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // CLEAR TOKENS (LOGOUT)
  // =====================================================
  Future<void> clearTokens() async {
    await db.delete(db.tokens).go();
  }
}
