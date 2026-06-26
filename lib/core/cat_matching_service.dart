import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class CatMatchResult {
  const CatMatchResult({
    required this.isMatch,
    required this.confidence,
    required this.message,
    required this.signature,
    this.existingCatId,
    this.existingCatName,
    this.existingLocationName,
  });

  final bool isMatch;
  final double confidence;
  final String message;
  final List<double> signature;
  final String? existingCatId;
  final String? existingCatName;
  final String? existingLocationName;
}

class CatMatchingService {
  CatMatchingService._();

  static final instance = CatMatchingService._();

  static const double _threshold = 0.84;

  List<double> buildSignature(Uint8List bytes) {
    final step = math.max(1, bytes.length ~/ 4096);
    double sum = 0;
    double sumSquares = 0;
    int warm = 0;
    int cool = 0;
    int count = 0;

    for (var index = 0; index < bytes.length; index += step) {
      final value = bytes[index];
      sum += value;
      sumSquares += value * value;
      if (value > 110 && value < 205) warm++;
      if (value >= 205 || value < 50) cool++;
      count++;
    }

    final mean = count > 0 ? sum / count : 128.0;
    final variance = count > 0 ? (sumSquares / count) - (mean * mean) : 0.0;
    final stdDev = math.sqrt(variance.abs());
    final warmRatio = count > 0 ? warm / count : 0.5;
    final coolRatio = count > 0 ? cool / count : 0.3;

    return [mean / 255.0, stdDev / 128.0, warmRatio, coolRatio];
  }

  Future<CatMatchResult> match(Uint8List bytes) async {
    final signature = buildSignature(bytes);
    final snapshot = await FirebaseFirestore.instance
        .collection('cats')
        .orderBy('lastUpdated', descending: true)
        .limit(50)
        .get();

    String? bestId;
    String? bestName;
    String? bestLocation;
    double bestScore = 0;

    for (final doc in snapshot.docs) {
      final rawSignature = doc.data()['imageSignature'];
      if (rawSignature is! List) continue;

      final existing = rawSignature.map((value) => (value as num).toDouble()).toList(growable: false);
      if (existing.length != signature.length) continue;

      final similarity = _similarity(signature, existing);
      if (similarity > bestScore) {
        bestScore = similarity;
        bestId = doc.id;
        bestName = (doc.data()['name'] ?? '').toString();
        bestLocation = (doc.data()['currentLocationName'] ?? '').toString();
      }
    }

    if (bestId != null && bestScore >= _threshold) {
      return CatMatchResult(
        isMatch: true,
        confidence: bestScore,
        message: 'This cat may already exist.',
        signature: signature,
        existingCatId: bestId,
        existingCatName: bestName,
        existingLocationName: bestLocation,
      );
    }

    return CatMatchResult(
      isMatch: false,
      confidence: bestScore,
      message: 'New cat detected.',
      signature: signature,
    );
  }

  double _similarity(List<double> a, List<double> b) {
    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (var index = 0; index < a.length; index++) {
      dot += a[index] * b[index];
      normA += a[index] * a[index];
      normB += b[index] * b[index];
    }

    if (normA == 0 || normB == 0) return 0;

    final cosine = dot / (math.sqrt(normA) * math.sqrt(normB));
    return cosine.clamp(0.0, 1.0);
  }
}