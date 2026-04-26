// lib/data/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:9090';

  // -----------------------------------
  // AUTH
  // -----------------------------------
  String get authUrl => '$baseUrl/auth/login';

  // -----------------------------------
  // HEALTH
  // -----------------------------------
  Future<Map<String, dynamic>> health() async {
    final res = await http.get(Uri.parse('$baseUrl/health'));

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }

    throw Exception('Backend not responding');
  }

  // -----------------------------------
  // SEARCH INSTRUMENTS
  // -----------------------------------
  Future<List<Map<String, dynamic>>> searchInstruments(
      String query,
      ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/instruments/search?q=$query'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      return data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  // -----------------------------------
  // PREDICTION
  // -----------------------------------
  Future<Map<String, dynamic>> getPrediction(
      String key,
      ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/predict/$key'),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(res.body),
      );
    }

    return {};
  }

  // -----------------------------------
  // CLUSTERS
  // -----------------------------------
  Future<List<Map<String, dynamic>>> getClusters() async {
    final res = await http.get(
      Uri.parse('$baseUrl/clusters'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      return data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  // -----------------------------------
  // LIVE PRICE
  // -----------------------------------
  Future<Map<String, dynamic>> getLivePrice(
      String key,
      ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/live/$key'),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(res.body),
      );
    }

    return {};
  }
}