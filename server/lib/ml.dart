// server/lib/ml.dart
//
// Machine Learning utility file
// Provides a simple regression model (NextHourModel)
// using ml_algo + ml_dataframe.
//
// Fully compatible with ml_algo >= 16.x.

import 'dart:convert';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_algo/ml_algo.dart';

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
  late List<String> _featureNames = [];

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

    final rows = <List<dynamic>>[
      [..._featureNames, 'target'],
    ];

    for (int i = 0; i < X.length; i++) {
      rows.add([...X[i], y[i]]);
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

    final df = DataFrame([
      _featureNames,
      features,
    ]);

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
      'model': _reg!.toJson(),
    });
  }

  static NextHourModel fromJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    final model = NextHourModel();
    if (data['trained'] == true) {
      model._featureNames = List<String>.from(data['features'] ?? []);
      final modelJson = data['model'];

      if (modelJson is Map<String, dynamic>) {
        model._reg = LinearRegressor.fromJson(jsonEncode(modelJson));
      }
    }
    return model;
  }
}
