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