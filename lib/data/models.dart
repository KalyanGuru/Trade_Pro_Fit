// lib/data/models.dart
//
// Data models for the Flutter app.
// Contains: Instrument, Tick, PredictionResponse, ConnectionStatus

// =====================================================
// CONNECTION STATUS
// =====================================================

enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
}

// =====================================================
// INSTRUMENT
// =====================================================

class Instrument {
  final String key;
  final String symbol;
  final String name;
                  
  Instrument({
    required this.key,
    required this.symbol,
    required this.name,
  });

  factory Instrument.fromJson(
      Map<String, dynamic> j) {
    return Instrument(
      key: (j['key'] ??
          j['instrument_key'] ??
          '')
          .toString(),

      symbol: (j['symbol'] ??
          '')
          .toString(),

      name: (j['name'] ??
          j['symbol'] ??
          '')
          .toString(),
    );
  }
}

// =====================================================
// TICK (LIVE PRICE FROM WEBSOCKET)
// =====================================================

class Tick {
  final String key;
  final int ts;
  final double ltp;

  Tick({
    required this.key,
    required this.ts,
    required this.ltp,
  });

  factory Tick.fromJson(
      Map<String, dynamic> j) {
    return Tick(
      key: (j['key'] ??
          j['instrument_key'] ??
          '')
          .toString(),

      ts: j['ts'] ?? 0,

      ltp: ((j['ltp'] ?? 0)
      as num)
          .toDouble(),
    );
  }
}

// =====================================================
// PREDICTION RESPONSE (FROM /predict ENDPOINT)
// =====================================================

class PredictionResponse {
  final double prediction;
  final String trend;
  final int confidence;
  final String clusterType;

  PredictionResponse({
    required this.prediction,
    required this.trend,
    required this.confidence,
    required this.clusterType,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> j) {
    return PredictionResponse(
      prediction: ((j['prediction'] ?? 0) as num).toDouble(),
      trend: (j['trend'] ?? 'SIDEWAYS').toString(),
      confidence: ((j['confidence'] ?? 0) as num).toInt(),
      clusterType: (j['cluster_type'] ?? 'neutral').toString(),
    );
  }

  /// Empty / fallback prediction
  factory PredictionResponse.empty() {
    return PredictionResponse(
      prediction: 0.0,
      trend: '-',
      confidence: 0,
      clusterType: 'neutral',
    );
  }
}

// =====================================================
// PREDICTION POINT (predicted vs actual — real data)
// =====================================================

class PredictionPoint {
  final int ts;
  final double predicted;
  final double actual;
  final double predictedReturn;
  final double actualReturn;

  PredictionPoint({
    required this.ts,
    required this.predicted,
    required this.actual,
    required this.predictedReturn,
    required this.actualReturn,
  });

  factory PredictionPoint.fromJson(Map<String, dynamic> j) {
    return PredictionPoint(
      ts: (j['ts'] ?? 0) as int,
      predicted: ((j['predicted'] ?? 0) as num).toDouble(),
      actual: ((j['actual'] ?? 0) as num).toDouble(),
      predictedReturn: ((j['predicted_return'] ?? 0) as num).toDouble(),
      actualReturn: ((j['actual_return'] ?? 0) as num).toDouble(),
    );
  }
}

// =====================================================
// METRICS RESPONSE (real ML metrics from server)
// =====================================================

class MetricsResponse {
  final List<PredictionPoint> predictions;
  final double mae;
  final double rmse;
  final List<double> maeHistory;
  final List<double> rmseHistory;
  final int dataPoints;
  final bool mlTrained;

  MetricsResponse({
    required this.predictions,
    required this.mae,
    required this.rmse,
    required this.maeHistory,
    required this.rmseHistory,
    required this.dataPoints,
    required this.mlTrained,
  });

  factory MetricsResponse.fromJson(Map<String, dynamic> j) {
    return MetricsResponse(
      predictions: (j['predictions'] as List? ?? [])
          .map((e) => PredictionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      mae: ((j['mae'] ?? 0) as num).toDouble(),
      rmse: ((j['rmse'] ?? 0) as num).toDouble(),
      maeHistory: (j['mae_history'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      rmseHistory: (j['rmse_history'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      dataPoints: (j['data_points'] ?? 0) as int,
      mlTrained: (j['ml_trained'] ?? false) as bool,
    );
  }

  factory MetricsResponse.empty() => MetricsResponse(
        predictions: [],
        mae: 0.0,
        rmse: 0.0,
        maeHistory: [],
        rmseHistory: [],
        dataPoints: 0,
        mlTrained: false,
      );
}