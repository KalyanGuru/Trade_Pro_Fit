class Instrument {
  final String key, symbol, name;
  Instrument({required this.key, required this.symbol, required this.name});
  factory Instrument.fromJson(Map<String, dynamic> j) => Instrument(
      key: j['instrument_key'], symbol: j['symbol'], name: j['name'] ?? j['symbol']
  );
}

class Tick {
  final String key;
  final int ts;
  final double ltp;
  Tick({required this.key, required this.ts, required this.ltp});
  factory Tick.fromJson(Map<String, dynamic> j) => Tick(
      key: j['instrument_key'], ts: j['ts'], ltp: (j['ltp'] as num).toDouble()
  );
}
