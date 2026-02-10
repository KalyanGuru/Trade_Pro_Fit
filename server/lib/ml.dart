// server/lib/ml.dart
//
// Machine Learning utility file
// Provides a simple regression model (NextHourModel)
// using ml_algo + ml_dataframe + ml_linalg.
//
// Fully compatible with ml_algo >= 16.x and ml_linalg >= 13.x

import 'dart:convert';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

/// A simple model wrapper for predicting the next hour’s return or price.
/// This uses a linear regression model trained on numerical features.
///
/// Example usage:
/// ```dart
/// final model = NextHourModel();
/// model.fit([[1.0, 2.0, 3.0], [2.0, 3.0, 4.0]], [10.0, 12.0]);
/// final pred = model.predict([2.5, 3.5, 4.5]);
/// print(pred);
/// ```
class NextHourModel {
  LinearRegressor? _reg;
  late List<String> _featureNames;

  /// Fit a regression model on given features (X) and target values (y).
  /// X: list of feature vectors (each is a List<double>)
  /// y: list of target doubles (same length as X)
  void fit(List<List<double>> X, List<double> y) {
    if (X.isEmpty || X.first.isEmpty) {
      throw ArgumentError('Feature matrix cannot be empty');
    }
    if (y.length != X.length) {
      throw ArgumentError('Targets and features must have same length');
    }

    // Create feature column names dynamically
    _featureNames =
        List.generate(X.first.length, (i) => 'f${i + 1}', growable: false);

    // Build rows: each row is a map {f1: val1, f2: val2, ..., target: val}
    final rows = <Map<String, dynamic>>[];
    for (int i = 0; i < X.length; i++) {
      final row = <String, dynamic>{};
      for (int j = 0; j < _featureNames.length; j++) {
        row[_featureNames[j]] = X[i][j];
      }
      row['target'] = y[i];
      rows.add(row);
    }

    final df = DataFrame(rows);

    _reg = LinearRegressor(
      df,
      'target',
      optimizerType: LinearOptimizerType.gradient,
      learningRateType: LearningRateType.constant,
      iterationsLimit: 500,
      randomSeed: 42,
    );

    print('✅ Model trained on ${X.length} samples, ${_featureNames.length} features.');
  }

  /// Predict a single sample (returns a double)
  double predict(List<double> features) {
    if (_reg == null) {
      throw StateError('Model has not been trained yet.');
    }
    if (features.length != _featureNames.length) {
      throw ArgumentError(
          'Expected ${_featureNames.length} features, got ${features.length}.');
    }

    // Prepare single-row DataFrame for prediction
    final row = <String, dynamic>{};
    for (int i = 0; i < _featureNames.length; i++) {
      row[_featureNames[i]] = features[i];
    }
    final df = DataFrame([row]);
    final result = _reg!.predict(df);
    final pred = result.rows.first.first;
    return pred is num ? pred.toDouble() : double.parse(pred.toString());
  }

  /// Export model parameters to JSON for caching or transfer.
  String toJson() {
    if (_reg == null) {
      return jsonEncode({'trained': false});
    }
    return jsonEncode({
      'trained': true,
      'features': _featureNames,
      'weights': _reg!.weights.toJson(),
    });
  }

  /// Import model weights from JSON (optional future extension)
  /// (Currently for placeholder — no inverse deserialization)
  static NextHourModel fromJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    final model = NextHourModel();
    if (data['trained'] == true) {
      model._featureNames = List<String>.from(data['features'] ?? []);
    }
    return model;
  }
}
