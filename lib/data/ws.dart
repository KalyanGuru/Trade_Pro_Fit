import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/env.dart';

class WsClient {
  WebSocketChannel? _ch;

  void connect(List<String> keys, void Function(List<dynamic>) onTicks) {
    _ch?.sink.close();
    final uri = Uri.parse(Env.backendBase.replaceFirst('http', 'ws') + '/ws/ltp');
    _ch = WebSocketChannel.connect(uri);
    _ch!.sink.add(jsonEncode({'subscribe': keys}));
    _ch!.stream.listen((message) {
      final m = jsonDecode(message);
      if (m['ticks'] != null) onTicks(m['ticks']);
      _ch!.sink.add('{}'); // ping
    });
  }

  void close() => _ch?.sink.close();
}
