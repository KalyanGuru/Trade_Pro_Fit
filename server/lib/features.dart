import 'dart:math';

class Bar {
  final int ts;
  final double o,h,l,c,v;
  Bar(this.ts, this.o, this.h, this.l, this.c, this.v);
}

class FeaturesResult {
  final List<int> ts;
  final Map<String, List<double>> cols;
  FeaturesResult(this.ts, this.cols);
}

List<double?> _ema(List<double?> x, int span) {
  final out = List<double?>.filled(x.length, null);
  double? prev;
  final k = 2.0 / (span + 1);
  for (var i=0;i<x.length;i++) {
    final xi = x[i];
    if (xi == null) { out[i] = prev; continue; }
    prev = prev == null ? xi : (xi * k + prev * (1 - k));
    out[i] = prev;
  }
  return out;
}

List<double?> _rsi(List<double?> close, int window) {
  double? prev;
  List<double?> gains = List.filled(close.length, null);
  List<double?> losses = List.filled(close.length, null);
  for (var i=0;i<close.length;i++) {
    final c = close[i];
    if (c==null) continue;
    if (prev!=null) {
      final diff = c - prev;
      gains[i] = max(0, diff);
      losses[i] = max(0, -diff);
    }
    prev = c;
  }
  final avgGain = _ema(gains, window);
  final avgLoss = _ema(losses, window);
  final rsi = List<double?>.filled(close.length, null);
  for (var i=0;i<close.length;i++) {
    final g = avgGain[i]; final l = avgLoss[i];
    if (g==null || l==null) continue;
    final rs = (l == 0) ? 1000.0 : (g / l);
    rsi[i] = 100 - (100 / (1 + rs));
  }
  return rsi;
}

List<double?> _atr(List<double?> h, List<double?> l, List<double?> c, int window) {
  final tr = List<double?>.filled(c.length, null);
  double? prevClose;
  for (var i=0;i<c.length;i++) {
    final hi=h[i], lo=l[i], ci=c[i];
    if (hi==null || lo==null || ci==null) { prevClose = ci ?? prevClose; continue; }
    final p = prevClose ?? ci;
    final v = max(hi - lo, max((hi - p).abs(), (lo - p).abs()));
    tr[i]=v;
    prevClose = ci;
  }
  return _ema(tr, window);
}

FeaturesResult computeFeatures(List<Bar> bars) {
  final n = bars.length;
  final ts = bars.map((e)=>e.ts).toList();
  final close = List<double?>.generate(n, (i)=>bars[i].c);
  final open  = List<double?>.generate(n, (i)=>bars[i].o);
  final high  = List<double?>.generate(n, (i)=>bars[i].h);
  final low   = List<double?>.generate(n, (i)=>bars[i].l);
  final vol   = List<double?>.generate(n, (i)=>bars[i].v);

  double? prev;
  final r1m = List<double?>.filled(n, null);
  for (var i=1;i<n;i++) {
    final c0 = bars[i-1].c; final c1 = bars[i].c;
    r1m[i] = log(c1/c0);
  }

  List<double?> ret(int k) {
    final out = List<double?>.filled(n, null);
    for (var i=k;i<n;i++) {
      out[i]=log(bars[i].c/bars[i-k].c);
    }
    return out;
  }

  final r5m = ret(5), r15m = ret(15);
  final ema20 = _ema(close, 20);
  final ema50 = _ema(close, 50);
  final d20 = List<double?>.generate(n, (i) => (close[i]!=null && ema20[i]!=null) ? ((close[i]! - ema20[i]!) / ema20[i]!) : null);
  final d50 = List<double?>.generate(n, (i) => (close[i]!=null && ema50[i]!=null) ? ((close[i]! - ema50[i]!) / ema50[i]!) : null);
  final ema20Slope = List<double?>.generate(n, (i) {
    if (i==0 || ema20[i]==null || close[i]==null || ema20[i-1]==null) return null;
    return (ema20[i]! - ema20[i-1]!) / close[i]!;
  });

  final rsi14 = _rsi(close, 14);
  final atr14Abs = _atr(high, low, close, 14);
  final atr14 = List<double?>.generate(n, (i) => (atr14Abs[i]!=null && close[i]!=null) ? (atr14Abs[i]!/close[i]!) : null);

  // realized vol 15
  final vol15 = List<double?>.filled(n, null);
  for (var i=14;i<n;i++) {
    final win = r1m.sublist(i-14, i+1).whereType<double>().toList();
    if (win.length==15) {
      final m = win.reduce((a,b)=>a+b)/win.length;
      final s = sqrt(win.map((x)=>pow(x-m,2).toDouble()).reduce((a,b)=>a+b)/win.length);
      vol15[i]=s;
    }
  }

  // VWAP-ish
  final vwap = List<double?>.filled(n, null);
  double pv=0, vv=0;
  for (var i=0;i<n;i++) {
    final c = close[i]; final v = vol[i];
    if (c==null || v==null) { vwap[i]= (vv>0? pv/vv : null); continue; }
    pv += c*v; vv += v;
    vwap[i]= (vv>0? pv/vv : null);
  }
  final dVwap = List<double?>.generate(n, (i) => (close[i]!=null && vwap[i]!=null) ? ((close[i]! - vwap[i]!) / vwap[i]!) : null);

  // Turnover5m and Volume surge
  final turnover5m = List<double?>.filled(n, null);
  for (var i=4;i<n;i++) {
    double sum=0; var ok=true;
    for (var j=i-4;j<=i;j++) {
      final c=close[j]; final v=vol[j];
      if (c==null || v==null) { ok=false; break; }
      sum += c*v;
    }
    turnover5m[i]= ok ? sum : null;
  }
  // vol ema20
  final volEma20 = _ema(vol, 20);
  final volSurge = List<double?>.generate(n, (i) => (vol[i]!=null && volEma20[i]!=null && volEma20[i]!=0) ? (vol[i]!/volEma20[i]!) : null);

  // target next 60m
  final target60 = List<double?>.filled(n, null);
  for (var i=0;i<n;i++) {
    double s=0; var ok=true;
    for (var k=1;k<=60;k++) {
      if (i+k>=n || r1m[i+k]==null) { ok=false; break; }
      s += r1m[i+k]!;
    }
    target60[i] = ok ? s : null;
  }

  return FeaturesResult(ts, {
    'r1m': r1m.whereType<double>().toList(), // optional
    'r5m': r5m.whereType<double?>().map((e)=>e??double.nan).toList(),
    'r15m': r15m.whereType<double?>().map((e)=>e??double.nan).toList(),
    'ema20': ema20.whereType<double>().toList(),
    'ema50': ema50.whereType<double>().toList(),
    'd20': d20.whereType<double>().toList(),
    'd50': d50.whereType<double>().toList(),
    'ema20_slope': ema20Slope.whereType<double>().toList(),
    'rsi14': rsi14.whereType<double>().toList(),
    'atr14': atr14.whereType<double>().toList(),
    'vol15': vol15.whereType<double>().toList(),
    'vwap': vwap.whereType<double>().toList(),
    'd_vwap': dVwap.whereType<double>().toList(),
    'turnover5m': turnover5m.whereType<double>().toList(),
    'vol_surge': volSurge.whereType<double>().toList(),
    'target_60': target60.whereType<double>().toList(),
  });
}
