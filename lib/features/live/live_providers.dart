import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_client.dart';
import '../../data/models.dart';
import '../../data/ws.dart';

// =========================================
// API & WS CLIENTS
// =========================================

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final wsClientProvider = Provider<WsClient>((ref) {
  final ws = WsClient();
  ref.onDispose(() => ws.dispose());
  return ws;
});

// =========================================
// SELECTED INSTRUMENT STATE
// =========================================

class SelectedInstrumentNotifier extends StateNotifier<Instrument?> {
  SelectedInstrumentNotifier() : super(null);

  void select(Instrument instrument) {
    state = instrument;
  }
}

final selectedInstrumentProvider =
    StateNotifierProvider<SelectedInstrumentNotifier, Instrument?>((ref) {
  return SelectedInstrumentNotifier();
});

// =========================================
// CONNECTION STATUS PROVIDER
// =========================================

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final ws = ref.watch(wsClientProvider);
  return ws.statusStream;
});

// =========================================
// LIVE DATA STREAM (WebSocket) — throttled
// =========================================

/// Keeps track of the latest LTP from the WebSocket stream.
/// Throttled to max 4 updates/sec to avoid UI thrashing.
final livePriceProvider = StreamProvider<double>((ref) {
  final ws = ref.watch(wsClientProvider);
  final selected = ref.watch(selectedInstrumentProvider);

  if (selected == null) {
    return const Stream.empty();
  }

  // Connect WebSocket to the selected instrument key
  ws.connect([selected.key]);

  // Throttle: emit at most every 250ms (4 fps)
  return ws.ticksStream
      .map((ticks) {
        final tick = ticks.firstWhere(
          (t) => t.key == selected.key,
          orElse: () => Tick(key: '', ts: 0, ltp: 0.0),
        );
        return tick.ltp;
      })
      .where((ltp) => ltp > 0)
      .transform(_ThrottleTransformer(const Duration(milliseconds: 250)));
});

/// StreamTransformer that throttles emissions.
class _ThrottleTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  const _ThrottleTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    return Stream<T>.eventTransformed(
      stream,
      (sink) => _ThrottleSink<T>(sink, duration),
    );
  }
}

class _ThrottleSink<T> implements EventSink<T> {
  final EventSink<T> _outputSink;
  final Duration _duration;
  Timer? _timer;
  T? _lastData;
  bool _hasData = false;

  _ThrottleSink(this._outputSink, this._duration);

  @override
  void add(T data) {
    _lastData = data;
    _hasData = true;
    if (_timer == null || !_timer!.isActive) {
      _outputSink.add(data);
      _hasData = false;
      _timer = Timer(_duration, () {
        if (_hasData) {
          _outputSink.add(_lastData as T);
          _hasData = false;
        }
      });
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _timer?.cancel();
    if (_hasData) {
      _outputSink.add(_lastData as T);
    }
    _outputSink.close();
  }
}

// =========================================
// ENHANCED PREDICTION DATA
// =========================================

class PredictionData {
  final List<double> priceHistory;
  final double prediction;
  final String trend;
  final int confidence;
  final String clusterType;
  final DateTime lastUpdated;

  PredictionData({
    required this.priceHistory,
    required this.prediction,
    required this.trend,
    required this.confidence,
    required this.clusterType,
    required this.lastUpdated,
  });

  factory PredictionData.empty() => PredictionData(
        priceHistory: [],
        prediction: 0.0,
        trend: '-',
        confidence: 0,
        clusterType: 'neutral',
        lastUpdated: DateTime.now(),
      );
}

// =========================================
// PREDICTION STREAM (polling)
// =========================================

final predictionProvider =
    StreamProvider.autoDispose<PredictionData>((ref) async* {
  final api = ref.watch(apiClientProvider);
  final selected = ref.watch(selectedInstrumentProvider);

  if (selected == null) {
    yield PredictionData.empty();
    return;
  }

  // Start the backend stream for the selected instrument
  try {
    await api.startStream(selected.key);
  } catch (e) {
    // Ignore — stream may already be running
  }

  // Polling loop
  while (true) {
    try {
      final candles = await api.getCandles(selected.key);
      final pred = await api.getPrediction(selected.key);

      final closes =
          candles.map((e) => (e['close'] as num).toDouble()).toList();

      yield PredictionData(
        priceHistory: closes,
        prediction: ((pred['prediction'] ?? 0) as num).toDouble(),
        trend: pred['trend']?.toString() ?? '-',
        confidence: ((pred['confidence'] ?? 0) as num).toInt(),
        clusterType: (pred['cluster_type'] ?? 'neutral').toString(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // On error, yield empty data but keep polling
    }

    // Poll every 5 seconds
    await Future.delayed(const Duration(seconds: 5));
  }
});

// =========================================
// ML METRICS STREAM (polling)
// =========================================

final metricsProvider = StreamProvider.autoDispose<MetricsResponse>((ref) async* {
  final api = ref.watch(apiClientProvider);
  final selected = ref.watch(selectedInstrumentProvider);

  if (selected == null) {
    yield MetricsResponse.empty();
    return;
  }

  // Polling loop
  while (true) {
    try {
      final metricsData = await api.getMetrics(selected.key);
      yield MetricsResponse.fromJson(metricsData);
    } catch (e) {
      // Ignore errors, wait for next poll
    }

    // Poll every 5 seconds
    await Future.delayed(const Duration(seconds: 5));
  }
});
