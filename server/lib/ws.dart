// server/lib/ws.dart
//
// WebSocket service for Kite Connect.
// Connects to wss://ws.kite.trade, subscribes to instruments,
// and parses Kite's binary tick packets.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:web_socket_channel/io.dart';

class WsService {
  IOWebSocketChannel? _channel;
  Timer? _heartbeatTimer;

  // =====================================================
  // CONNECT TO KITE WEBSOCKET
  // =====================================================
  Future<void> connect({
    required String wsUrl,
    required List<int> tokens,
    required Function(Map<String, dynamic>) onTick,
  }) async {
    // Close any existing connection first
    close();

    print('🔗 Connecting to Kite WS...');
    print('URL: $wsUrl');

    _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

    // Wait briefly for connection to establish
    await Future.delayed(const Duration(milliseconds: 500));

    // Subscribe using integer instrument tokens (Kite protocol)
    final subMsg = jsonEncode({
      'a': 'subscribe',
      'v': tokens,
    });
    _channel!.sink.add(subMsg);
    print('✅ WS SUBSCRIBED: $tokens');

    // Set mode to "full" for complete tick data (OHLCV + depth)
    final modeMsg = jsonEncode({
      'a': 'mode',
      'v': ['full', tokens],
    });
    _channel!.sink.add(modeMsg);
    print('✅ WS MODE SET: full');

    _channel!.stream.listen(
      (msg) {
        try {
          // ---------- CASE 1: TEXT FRAME ----------
          if (msg is String) {
            _handleTextFrame(msg, onTick);
            return;
          }

          // ---------- CASE 2: BINARY FRAME ----------
          Uint8List bytes;
          if (msg is Uint8List) {
            bytes = msg;
          } else if (msg is List<int>) {
            bytes = Uint8List.fromList(msg);
          } else {
            print('⚠️ Unknown WS message type: ${msg.runtimeType}');
            return;
          }

          // Heartbeat filter: 1–2 byte frames are heartbeats
          if (bytes.length < 4) {
            return; // Silently skip heartbeats
          }

          _handleBinaryFrame(bytes, onTick);
        } catch (e) {
          print('❌ WS FRAME ERROR: $e');
        }
      },
      onError: (e) {
        print('❌ WS CONNECTION ERROR: $e');
      },
      onDone: () {
        print('🔌 WS CLOSED');
      },
    );
  }

  // =====================================================
  // TEXT FRAME HANDLER
  // =====================================================
  void _handleTextFrame(
      String msg, Function(Map<String, dynamic>) onTick) {
    final preview = msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
    print('📝 TEXT FRAME: $preview');

    try {
      final j = jsonDecode(msg);

      // Some Kite responses come as JSON (e.g. order postbacks)
      if (j is Map && j.containsKey('type')) {
        if (j['type'] == 'order') {
          print('📋 Order update received');
        }
        return;
      }

      // Handle JSON tick data if present (fallback)
      if (j is Map && j.containsKey('data')) {
        final data = j['data'];
        if (data is List) {
          for (final tick in data) {
            if (tick is Map) {
              final ltp = (tick['last_price'] ?? tick['ltp'] ?? 0).toDouble();
              final key = tick['instrument_token']?.toString() ?? '';
              if (ltp > 0 && key.isNotEmpty) {
                print('🔥 LIVE (json): $key -> $ltp');
                onTick({
                  'instrument_key': key,
                  'ltp': ltp,
                });
              }
            }
          }
        }
      }
    } catch (_) {
      // Ignore non-JSON text frames
    }
  }

  // =====================================================
  // BINARY FRAME HANDLER (KITE TICK PROTOCOL)
  // =====================================================
  /// Kite binary format:
  ///   - First 2 bytes: number of packets (big-endian Int16)
  ///   - For each packet:
  ///     - 2 bytes: packet length (big-endian Int16)
  ///     - N bytes: packet data
  ///
  /// Packet data layout (by size):
  ///   -  8 bytes → LTP mode (token 4B + LTP 4B)
  ///   - 44 bytes → Quote mode (token + OHLCV + more)
  ///   - 184 bytes → Full mode (quote + depth)
  void _handleBinaryFrame(
      Uint8List bytes, Function(Map<String, dynamic>) onTick) {
    final bd = ByteData.sublistView(bytes);
    
    // Number of packets in this frame
    if (bytes.length < 2) return;
    final numPackets = bd.getInt16(0, Endian.big);

    if (numPackets <= 0 || numPackets > 200) {
      print('⚠️ Invalid packet count: $numPackets');
      return;
    }

    int offset = 2;

    for (int i = 0; i < numPackets; i++) {
      if (offset + 2 > bytes.length) break;

      final packetLen = bd.getInt16(offset, Endian.big);
      offset += 2;

      if (packetLen <= 0 || offset + packetLen > bytes.length) break;

      final packetData = ByteData.sublistView(bytes, offset, offset + packetLen);
      _parseTickPacket(packetData, packetLen, onTick);

      offset += packetLen;
    }
  }

  /// Parse a single tick packet based on its size.
  void _parseTickPacket(
      ByteData data, int len, Function(Map<String, dynamic>) onTick) {
    if (len < 8) return; // minimum: token(4) + ltp(4)

    final instrumentToken = data.getInt32(0, Endian.big);
    final ltp = data.getInt32(4, Endian.big) / 100.0; // Kite sends price * 100

    final tick = <String, dynamic>{
      'instrument_key': instrumentToken.toString(),
      'ltp': ltp,
    };

    // Quote mode (44 bytes) — extract OHLCV
    if (len >= 44) {
      tick['high'] = data.getInt32(8, Endian.big) / 100.0;
      tick['low'] = data.getInt32(12, Endian.big) / 100.0;
      tick['open'] = data.getInt32(16, Endian.big) / 100.0;
      tick['close'] = data.getInt32(20, Endian.big) / 100.0;
      // Volume is at offset 24, unsigned 32-bit (we read as signed, fine for most)
      tick['volume'] = data.getInt32(28, Endian.big);
    }

    if (ltp > 0) {
      print('🔥 LIVE: token=$instrumentToken -> ₹$ltp');
      onTick(tick);
    }
  }

  // =====================================================
  // CLOSE
  // =====================================================
  void close() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}