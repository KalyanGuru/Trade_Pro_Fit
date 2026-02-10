import 'package:dio/dio.dart';
import '../core/env.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.backendBase));

  Future<List<Map<String, dynamic>>> searchInstruments(String q) async {
    final r = await _dio.get('/instruments/search', queryParameters: {'q': q});
    return List<Map<String, dynamic>>.from(r.data['data']);
  }

  Future<Map<String, dynamic>> getPrediction(String instrumentKey) async {
    final r = await _dio.get('/features/prediction', queryParameters: {'instrument_key': instrumentKey});
    return Map<String, dynamic>.from(r.data);
  }

  Future<List<Map<String, dynamic>>> getClusters() async {
    final r = await _dio.get('/clusters/latest');
    return List<Map<String, dynamic>>.from(r.data['data']);
  }

  String get authUrl => '${Env.backendBase}/auth/login';
}
