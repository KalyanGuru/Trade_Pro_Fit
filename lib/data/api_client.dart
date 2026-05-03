// lib/data/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
class ApiClient {
  /// Backend running in Dart server
  static const String baseUrl = Env.backendBase;

  // =====================================================
  // COMMON GET REQUEST
  // =====================================================

  Future<dynamic> _get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Request failed (${response.statusCode}) -> $endpoint',
    );
  }

  // =====================================================
  // AUTH
  // =====================================================

  String get authUrl => '$baseUrl/auth/login';

  // =====================================================
  // HEALTH CHECK
  // =====================================================

  Future<Map<String, dynamic>> health() async {
    final data = await _get('/health');

    return Map<String, dynamic>.from(data);
  }

  Future<bool> isConnected() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auth/status'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['connected'] == true;
    }

    return false;
  }

  // =====================================================
  // SEARCH STOCKS / INSTRUMENTS
  // =====================================================

  Future<List<Map<String, dynamic>>> searchInstruments(
      String query,
      ) async {
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
  // GET AI PREDICTION
  // =====================================================

  Future<Map<String, dynamic>> getPrediction(
      String instrumentKey,
      ) async {
    final data = await _get('/predict/$instrumentKey');

    return Map<String, dynamic>.from(data);
  }

  // =====================================================
  // GET CLUSTER DATA
  // =====================================================

  Future<List<Map<String, dynamic>>> getClusters() async {
    final data = await _get('/clusters');

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // =====================================================
  // LIVE PRICE
  // =====================================================

  Future<Map<String, dynamic>> getLivePrice(
      String instrumentKey,
      ) async {
    final data = await _get('/live/$instrumentKey');

    return Map<String, dynamic>.from(data);
  }

  // =====================================================
  // OHLC CANDLE DATA
  // =====================================================

  Future<List<Map<String, dynamic>>> getCandles(
      String instrumentKey,
      ) async {
    final data = await _get('/candles/$instrumentKey');

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}