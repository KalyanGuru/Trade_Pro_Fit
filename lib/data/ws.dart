// lib/data/ws.dart
//
// WebSocket client for Flutter.
// Connects to the backend /ws/ltp endpoint, receives tick broadcasts,
// and provides a stream of Tick objects to the UI layer.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/env.dart';
import 'models.dart';

class WsClient {
  WebSocketChannel? _ch;
  Timer? _reconnectTimer;
  List<String> _currentKeys = [];
  bool _isConnecting = false;
  int _reconnectAttempts = 0;

  // Maximum reconnect attempts before giving up
  static const int _maxReconnectAttempts = 15;

  // =====================================================
  // TICK STREAM
  // =====================================================
  final _ticksController = StreamController<List<Tick>>.broadcast();
  Stream<List<Tick>> get ticksStream => _ticksController.stream;

  // =====================================================
  // CONNECTION STATUS STREAM
  // =====================================================
  final _statusController =
      StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentStatus => _currentStatus;

  void _setStatus(ConnectionStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  // =====================================================
  // CONNECT
  // =====================================================
  void connect(List<String> keys) {
    if (listEquals(_currentKeys, keys) && _ch != null) {
      return; // Already connected to these keys
    }

    _currentKeys = keys;
    _reconnectAttempts = 0;
    _initConnection();
  }

  // =====================================================
  // INIT CONNECTION
  // =====================================================
  void _initConnection() {
    if (_isConnecting) return;
    _isConnecting = true;
    _setStatus(ConnectionStatus.reconnecting);

    _ch?.sink.close();

    try {
      final uri = Uri.parse(
        '${Env.backendBase.replaceFirst('http', 'ws')}/ws/ltp',
      );

      debugPrint('[WS] Connecting to $uri');

      _ch = WebSocketChannel.connect(uri);

      if (_currentKeys.isNotEmpty) {
        _ch!.sink.add(jsonEncode({'subscribe': _currentKeys}));
        debugPrint('[WS] Subscribed to: $_currentKeys');
      }

      _ch!.stream.listen(
        (message) {
          // Reset reconnect counter on successful data
          _reconnectAttempts = 0;
          _setStatus(ConnectionStatus.connected);

          try {
            final m = jsonDecode(message);
            if (m['ticks'] != null) {
              final ticksList = (m['ticks'] as List)
                  .map((t) =>
                      Tick.fromJson(t as Map<String, dynamic>))
                  .toList();
              if (!_ticksController.isClosed) {
                _ticksController.add(ticksList);
              }
            }
          } catch (e) {
            debugPrint('[WS] Parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('[WS] Error: $error');
          _setStatus(ConnectionStatus.disconnected);
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[WS] Connection closed');
          _setStatus(ConnectionStatus.disconnected);
          _scheduleReconnect();
        },
      );

      _isConnecting = false;
    } catch (e) {
      debugPrint('[WS] Connection failed: $e');
      _isConnecting = false;
      _setStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  // =====================================================
  // RECONNECT WITH EXPONENTIAL BACKOFF
  // =====================================================
  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WS] Max reconnect attempts reached');
      _setStatus(ConnectionStatus.disconnected);
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff: 1s, 2s, 4s, 8s... capped at 30s
    final delay = min(pow(2, _reconnectAttempts).toInt(), 30);

    debugPrint(
        '[WS] Reconnecting in ${delay}s (attempt $_reconnectAttempts)');
    _setStatus(ConnectionStatus.reconnecting);

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _initConnection();
    });
  }

  // =====================================================
  // CLOSE
  // =====================================================
  void close() {
    _reconnectTimer?.cancel();
    _ch?.sink.close();
    _ch = null;
    _currentKeys = [];
    _reconnectAttempts = 0;
    _setStatus(ConnectionStatus.disconnected);
  }

  // =====================================================
  // DISPOSE
  // =====================================================
  void dispose() {
    close();
    _ticksController.close();
    _statusController.close();
  }
}
