// lib/data/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';

class ApiClient {
  static const String baseUrl = Env.backendBase;
  static const _timeout = Duration(seconds: 10);
  static const _maxRetries = 2;

  // =====================================================
  // COMMON GET (with timeout & retry)
  // =====================================================

  Future<dynamic> _get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final res = await http.get(uri).timeout(_timeout);

        if (res.statusCode == 200) {
          return jsonDecode(res.body);
        }

        // Don't retry on 4xx client errors
        if (res.statusCode >= 400 && res.statusCode < 500) {
          throw Exception('GET failed (${res.statusCode}) → $endpoint');
        }

        // Retry on 5xx server errors
        if (attempt == _maxRetries) {
          throw Exception('GET failed (${res.statusCode}) → $endpoint');
        }
      } catch (e) {
        if (attempt == _maxRetries) rethrow;
        // Wait briefly before retry
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    throw Exception('GET failed → $endpoint');
  }

  // =====================================================
  // AUTH
  // =====================================================

  String get authUrl => '$baseUrl/auth/login';

  Future<bool> isConnected() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/auth/status'))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['connected'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/auth/logout')).timeout(_timeout);
  }

  // =====================================================
  // HEALTH
  // =====================================================

  Future<Map<String, dynamic>> health() async {
    final data = await _get('/health');
    return Map<String, dynamic>.from(data);
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<List<Map<String, dynamic>>> searchInstruments(
      String query) async {
    if (query.trim().isEmpty) return [];

    final data = await _get(
      '/instruments/search?q=${Uri.encodeComponent(query)}',
    );

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // =====================================================
  // START STREAM
  // =====================================================

  Future<void> startStream(String instrumentKey) async {
    final uri = Uri.parse(
      '$baseUrl/start/${Uri.encodeComponent(instrumentKey)}',
    );

    final res = await http.get(uri).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Failed to start stream');
    }
  }

  // =====================================================
  // GET LIVE CANDLES
  // =====================================================

  Future<List<Map<String, dynamic>>> getCandles(
      String instrumentKey) async {
    final data = await _get(
      '/candles/${Uri.encodeComponent(instrumentKey)}',
    );

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // =====================================================
  // PREDICTION
  // =====================================================

  Future<Map<String, dynamic>> getPrediction(
      String instrumentKey) async {
    final data = await _get(
      '/predict/${Uri.encodeComponent(instrumentKey)}',
    );

    return Map<String, dynamic>.from(data);
  }

  // =====================================================
  // CLUSTERS
  // =====================================================

  Future<List<Map<String, dynamic>>> getClusters() async {
    final data = await _get('/clusters');

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // =====================================================
  // ML METRICS (real prediction history + MAE + RMSE)
  // =====================================================

  Future<Map<String, dynamic>> getMetrics(
      String instrumentKey) async {
    final data = await _get(
      '/metrics/${Uri.encodeComponent(instrumentKey)}',
    );

    return Map<String, dynamic>.from(data);
  }
}