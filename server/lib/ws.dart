import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:drift/drift.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'db.dart';

Handler ltpHandler(AppDb db) {
  return webSocketHandler((WebSocketChannel ch) async {
    final subs = <String>{};
    final subCtrl = StreamController<void>();
    ch.stream.listen((msg) {
      // Expect {"subscribe":["instrument_key", ...]}
      try {
        final m = jsonDecode(msg as String) as Map<String, dynamic>;
        final arr = (m['subscribe'] as List?)?.cast<String>() ?? const <String>[];
        subs
          ..clear()
          ..addAll(arr);
        subCtrl.add(null);
      } catch (_) {}
    });

    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (subs.isEmpty) return;
      final out = <Map<String, dynamic>>[];
      for (final k in subs) {
        final q = db.customSelect(
          'SELECT ts, close FROM minute_bars WHERE instrument_key=? ORDER BY ts DESC LIMIT 1',
          variables: [Variable.withString(k)],
          readsFrom: {db.minuteBars},
        );
        final row = await q.getSingleOrNull();
        if (row != null) {
          out.add({'instrument_key': k, 'ts': row.data['ts'], 'ltp': row.data['close']});
        }
      }
      ch.sink.add(jsonEncode({'ticks': out}));
    });
  });
}
