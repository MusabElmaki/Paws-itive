import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../ml/prediction_result.dart';

class MLService {
  static final MLService _instance = MLService._();

  factory MLService() => _instance;

  MLService._();

  Future<void> initialize() async {
    debugPrint('[MLService] Heuristic mode enabled');
  }

  Future<PredictionResult> classify(Uint8List imageBytes) async {
    return _pixelHeuristic(imageBytes);
  }

  void dispose() {}

  PredictionResult _pixelHeuristic(Uint8List bytes) {
    final step = math.max(1, bytes.length ~/ 4096);

    double sum = 0;
    double sumSq = 0;

    int warm = 0;
    int cool = 0;
    int checksum = 0;
    int count = 0;

    for (int i = 0; i < bytes.length; i += step) {
      final v = bytes[i];

      sum += v;
      sumSq += v * v;

      checksum ^= (v << (i % 8));

      if (v > 110 && v < 205) {
        warm++;
      }

      if (v >= 205 || v < 50) {
        cool++;
      }

      count++;
    }

    final mean = count > 0 ? sum / count : 128.0;
    final variance = count > 0 ? (sumSq / count) - (mean * mean) : 0.0;

    final stdDev = math.sqrt(variance.abs());

    final warmRatio = count > 0 ? warm / count : 0.5;
    final coolRatio = count > 0 ? cool / count : 0.3;

    final rng = math.Random(checksum);

    double cat = 0;
    double other = 0;

    if (warmRatio > 0.33 && stdDev > 38 && stdDev < 90) {
      cat += 0.50;
    }

    if (mean > 100 && mean < 165) {
      cat += 0.20;
    }

    if (coolRatio > 0.32 || stdDev < 28 || stdDev > 105) {
      other += 0.42;
    }

    if (mean < 78 || mean > 182) {
      other += 0.25;
    }

    cat += rng.nextDouble() * 0.14;
    other += rng.nextDouble() * 0.14;

    final scores = _softmax([
      cat,
      other,
    ]);

    int maxIndex = 0;

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[maxIndex]) {
        maxIndex = i;
      }
    }

    const labels = [
      'Cat',
      'Other',
    ];

    return PredictionResult(
      label: labels[maxIndex],
      confidence: scores[maxIndex],
      success: true,
    );
  }

  List<double> _softmax(List<double> values) {
    final maxValue = values.reduce(math.max);

    final exps = values.map((e) => math.exp(e - maxValue)).toList();

    final sum = exps.fold<double>(
      0,
          (a, b) => a + b,
    );

    return exps.map((e) => e / sum).toList();
  }
}