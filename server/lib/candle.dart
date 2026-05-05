// server/lib/candle.dart
//
// Stores real-time tick data and builds minute-bars for ML feature engineering.
// Also tracks prediction history for MAE/RMSE computation.

import 'dart:math';
import 'features.dart';

/// A single prediction record — predicted vs actual outcome.
class PredictionRecord {
  final int ts;           // epoch ms when prediction was made
  final double predicted; // predicted price (LTP + predicted return)
  final double actual;    // actual price at that moment (current LTP)
  final double predictedReturn; // raw predicted return from ML
  final double actualReturn;    // actual return that occurred

  PredictionRecord({
    required this.ts,
    required this.predicted,
    required this.actual,
    required this.predictedReturn,
    required this.actualReturn,
  });

  Map<String, dynamic> toJson() => {
    'ts': ts,
    'predicted': double.parse(predicted.toStringAsFixed(2)),
    'actual': double.parse(actual.toStringAsFixed(2)),
    'predicted_return': double.parse(predictedReturn.toStringAsFixed(6)),
    'actual_return': double.parse(actualReturn.toStringAsFixed(6)),
  };
}

class CandleBuilder {
  // Raw tick prices per instrument (for price chart & basic predictions)
  final Map<String, List<double>> _prices = {};

  // Full OHLCV bars built from ticks (for ML feature engineering)
  final Map<String, List<Bar>> _bars = {};

  // Current minute candle being built
  final Map<String, _MinuteCandle> _currentCandle = {};

  // Prediction history per instrument (predicted vs actual)
  final Map<String, List<PredictionRecord>> _predictionHistory = {};

  // Last prediction price per instrument (to compute actual return later)
  final Map<String, _PendingPrediction> _pendingPredictions = {};

  // =====================================================
  // ADD TICK — stores raw price + builds minute bars
  // =====================================================
  void addTick(Map<String, dynamic> tick) {
    final key = tick['instrument_key']?.toString();
    final ltp = (tick['ltp'] as num?)?.toDouble();

    if (key == null || ltp == null) return;

    // Store raw price
    _prices.putIfAbsent(key, () => []);
    _prices[key]!.add(ltp);
    if (_prices[key]!.length > 500) {
      _prices[key]!.removeAt(0);
    }

    // Build 15-second candle (faster for real-time ML)
    final now = DateTime.now();
    final secondSlot = (now.second ~/ 15) * 15;
    final minuteTs = DateTime(now.year, now.month, now.day, now.hour, now.minute, secondSlot)
        .millisecondsSinceEpoch ~/ 1000;

    _currentCandle.putIfAbsent(key, () => _MinuteCandle(minuteTs, ltp));

    final candle = _currentCandle[key]!;

    if (candle.ts != minuteTs) {
      // New 15-second slot — finalize the old candle and start a new one
      _bars.putIfAbsent(key, () => []);
      _bars[key]!.add(Bar(
        candle.ts,
        candle.open,
        candle.high,
        candle.low,
        candle.close,
        candle.volume,
      ));

      // Keep last 500 bars for feature computation
      if (_bars[key]!.length > 500) {
        _bars[key]!.removeAt(0);
      }

      // Start new candle
      _currentCandle[key] = _MinuteCandle(minuteTs, ltp);
    } else {
      // Same slot — update the candle
      candle.high = max(candle.high, ltp);
      candle.low = min(candle.low, ltp);
      candle.close = ltp;
      final volume = (tick['volume'] as num?)?.toDouble();
      if (volume != null) candle.volume += volume;
    }

    // Resolve any pending prediction on every tick
    _resolvePendingPrediction(key, ltp);
  }

  // =====================================================
  // GET RAW PRICES (for price line chart)
  // =====================================================
  List<double> get(String key) {
    return _prices[key] ?? [];
  }

  // =====================================================
  // GET BARS (for ML feature engineering)
  // =====================================================
  List<Bar> getBars(String key) {
    return _bars[key] ?? [];
  }

  // =====================================================
  // GET CURRENT LTP
  // =====================================================
  double? getCurrentLtp(String key) {
    final prices = _prices[key];
    if (prices == null || prices.isEmpty) return null;
    return prices.last;
  }

  // =====================================================
  // PREDICTION TRACKING
  // =====================================================

  /// Record a new ML prediction for later evaluation.
  void recordPrediction(String key, double predictedReturn, double currentLtp) {
    _pendingPredictions[key] = _PendingPrediction(
      ts: DateTime.now().millisecondsSinceEpoch,
      predictedReturn: predictedReturn,
      priceAtPrediction: currentLtp,
    );
  }

  /// Resolve a pending prediction when new data arrives.
  void _resolvePendingPrediction(String key, double currentLtp) {
    final pending = _pendingPredictions[key];
    if (pending == null) return;

    final actualReturn = (currentLtp - pending.priceAtPrediction) /
        pending.priceAtPrediction;
    final predictedPrice =
        pending.priceAtPrediction * (1 + pending.predictedReturn);

    _predictionHistory.putIfAbsent(key, () => []);
    _predictionHistory[key]!.add(PredictionRecord(
      ts: pending.ts,
      predicted: predictedPrice,
      actual: currentLtp,
      predictedReturn: pending.predictedReturn,
      actualReturn: actualReturn,
    ));

    // Keep last 200 records
    if (_predictionHistory[key]!.length > 200) {
      _predictionHistory[key]!.removeAt(0);
    }

    _pendingPredictions.remove(key);
  }

  /// Get prediction history for an instrument.
  List<PredictionRecord> getPredictionHistory(String key) {
    return _predictionHistory[key] ?? [];
  }

  /// Compute rolling MAE from prediction history.
  List<double> getRollingMAE(String key) {
    final history = _predictionHistory[key] ?? [];
    if (history.isEmpty) return [];

    final mae = <double>[];
    double sumAbsError = 0;

    for (int i = 0; i < history.length; i++) {
      sumAbsError += (history[i].predicted - history[i].actual).abs();
      mae.add(sumAbsError / (i + 1));
    }

    return mae;
  }

  /// Compute rolling RMSE from prediction history.
  List<double> getRollingRMSE(String key) {
    final history = _predictionHistory[key] ?? [];
    if (history.isEmpty) return [];

    final rmse = <double>[];
    double sumSqError = 0;

    for (int i = 0; i < history.length; i++) {
      final error = history[i].predicted - history[i].actual;
      sumSqError += error * error;
      rmse.add(sqrt(sumSqError / (i + 1)));
    }

    return rmse;
  }

  /// Current MAE value
  double? getCurrentMAE(String key) {
    final rolling = getRollingMAE(key);
    return rolling.isEmpty ? null : rolling.last;
  }

  /// Current RMSE value
  double? getCurrentRMSE(String key) {
    final rolling = getRollingRMSE(key);
    return rolling.isEmpty ? null : rolling.last;
  }

  /// Check if we have enough bars for ML (15 bars × 15sec = ~4 min)
  bool hasEnoughData(String key) {
    return (_bars[key]?.length ?? 0) >= 15;
  }
}

// =====================================================
// INTERNAL HELPERS
// =====================================================

class _MinuteCandle {
  final int ts;
  final double open;
  double high;
  double low;
  double close;
  double volume;

  _MinuteCandle(this.ts, double price)
      : open = price,
        high = price,
        low = price,
        close = price,
        volume = 0;
}

class _PendingPrediction {
  final int ts;
  final double predictedReturn;
  final double priceAtPrediction;

  _PendingPrediction({
    required this.ts,
    required this.predictedReturn,
    required this.priceAtPrediction,
  });
}