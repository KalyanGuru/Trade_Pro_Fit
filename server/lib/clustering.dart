import 'dart:math';

import 'package:ml_linalg/matrix.dart';

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
  if (X.rowCount < k * 30) return null;
  final labels = _kMeansLabels(X, k: k, seed: 42);

  // Profitability scoring by rule: RSI in [45, 60], d20>0 -> avg target_60
  final scores = <int, List<double>>{};
  for (var i = 0; i < labels.length; i++) {
    final cond = (rsi[i] >= 45 && rsi[i] <= 60 && d20[i] > 0);
    if (!cond) continue;
    scores.putIfAbsent(labels[i], () => []);
    scores[labels[i]]!.add(target60[i]);
  }
  final avg = <int, double>{};
  scores.forEach((c, list) {
    if (list.isEmpty) return;
    avg[c] = list.reduce((a, b) => a + b) / list.length;
  });
  final sorted = avg.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final names = <int, String>{};
  for (var i = 0; i < sorted.length; i++) {
    names[sorted[i].key] =
    i < (sorted.length / 2).ceil() ? 'profitable' : 'neutral';
  }
  return ClusterOutput(labels, names);
}

List<int> _kMeansLabels(
    Matrix x, {
      required int k,
      required int seed,
      int maxIterations = 100,
    }) {
  final rows = x.rows.map((row) => row.toList(growable: false)).toList();
  final random = Random(seed);
  final centers = <List<double>>[];
  final used = <int>{};

  while (centers.length < k) {
    final idx = random.nextInt(rows.length);
    if (used.add(idx)) {
      centers.add(List<double>.from(rows[idx], growable: false));
    }
  }

  final labels = List<int>.filled(rows.length, 0);

  for (var iteration = 0; iteration < maxIterations; iteration++) {
    var changed = false;

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final nextLabel = _nearestCenter(rows[rowIndex], centers);
      if (labels[rowIndex] != nextLabel) {
        labels[rowIndex] = nextLabel;
        changed = true;
      }
    }

    if (!changed && iteration > 0) break;

    final sums = List.generate(
      k,
          (_) => List<double>.filled(x.columnCount, 0),
    );
    final counts = List<int>.filled(k, 0);

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final label = labels[rowIndex];
      counts[label]++;

      for (var col = 0; col < x.columnCount; col++) {
        sums[label][col] += rows[rowIndex][col];
      }
    }

    for (var center = 0; center < k; center++) {
      if (counts[center] == 0) {
        centers[center] = List<double>.from(
          rows[random.nextInt(rows.length)],
          growable: false,
        );
        continue;
      }

      for (var col = 0; col < x.columnCount; col++) {
        centers[center][col] = sums[center][col] / counts[center];
      }
    }
  }

  return labels;
}

int _nearestCenter(List<double> row, List<List<double>> centers) {
  var bestLabel = 0;
  var bestDistance = double.infinity;

  for (var label = 0; label < centers.length; label++) {
    final distance = _squaredDistance(row, centers[label]);
    if (distance < bestDistance) {
      bestLabel = label;
      bestDistance = distance;
    }
  }

  return bestLabel;
}

double _squaredDistance(List<double> a, List<double> b) {
  var sum = 0.0;

  for (var i = 0; i < a.length; i++) {
    final diff = a[i] - b[i];
    sum += diff * diff;
  }

  return sum;
}