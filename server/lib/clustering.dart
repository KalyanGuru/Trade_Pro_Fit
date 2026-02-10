import 'package:ml_algo/ml_algo.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';
import 'package:ml_algo/ml_algo.dart';

class ClusterOutput {
  final List<int> labels; // length = rows
  final Map<int, String> labelNames; // cluster -> 'profitable'/'neutral'
  ClusterOutput(this.labels, this.labelNames);
}

ClusterOutput? kmeansCluster({
  required Matrix X, // rows x features
  required List<double> rsi, // for profitability rule
  required List<double> d20,
  required List<double> target60,
  int k = 5,
}) {
  if (X.rowsNum < k * 30) return null;
  final km = KMeans (X, k: k, seed: 42);

  final labels = km.predict(X).map((v) => v[0].round()).toList();

  // Profitability scoring by rule: RSI in [45, 60], d20>0 -> avg target_60
  final scores = <int, List<double>>{};
  for (var i=0;i<labels.length;i++) {
    final cond = (rsi[i] >= 45 && rsi[i] <= 60 && d20[i] > 0);
    if (!cond) continue;
    scores.putIfAbsent(labels[i], ()=>[]);
    scores[labels[i]]!.add(target60[i]);
  }
  final avg = <int,double>{};
  scores.forEach((c, list) {
    if (list.isEmpty) return;
    avg[c] = list.reduce((a,b)=>a+b)/list.length;
  });
  final sorted = avg.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
  final names = <int,String>{};
  for (var i=0;i<sorted.length;i++) {
    names[sorted[i].key] = i < (sorted.length/2).ceil() ? 'profitable' : 'neutral';
  }
  return ClusterOutput(labels, names);
}
