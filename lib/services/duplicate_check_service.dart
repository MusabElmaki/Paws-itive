import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../ml/duplicate_check_result.dart';

/// DEMO duplicate-cat detection service.
///
/// Computes a small numeric "signature" from an image's pixel bytes, then
/// compares it against the signatures already saved on previous reports in
/// Firestore (`reports/{id}.imageSignature`). If a close match is found,
/// the new report is flagged as a possible duplicate of an existing case.
///
/// This is intentionally NOT a real image-recognition model — there is no
/// trained network, no embeddings, no face/coat matching. It is a fast,
/// good-enough stand-in to demonstrate the stakeholder's requested
/// "has this cat already been reported?" workflow during the presentation.
class DuplicateCheckService {
  static final DuplicateCheckService _instance = DuplicateCheckService._();

  factory DuplicateCheckService() => _instance;

  DuplicateCheckService._();

  /// Match threshold — signatures with similarity above this are flagged.
  static const double _matchThreshold = 0.82;

  /// Computes a lightweight signature (4 numbers) describing the image.
  /// Kept deliberately simple — this is a demo, not a vision model.
  List<double> computeSignature(Uint8List bytes) {
    final step = math.max(1, bytes.length ~/ 4096);

    double sum = 0;
    double sumSq = 0;
    int warm = 0;
    int cool = 0;
    int count = 0;

    for (int i = 0; i < bytes.length; i += step) {
      final v = bytes[i];
      sum += v;
      sumSq += v * v;

      if (v > 110 && v < 205) warm++;
      if (v >= 205 || v < 50) cool++;

      count++;
    }

    final mean = count > 0 ? sum / count : 128.0;
    final variance = count > 0 ? (sumSq / count) - (mean * mean) : 0.0;
    final stdDev = math.sqrt(variance.abs());
    final warmRatio = count > 0 ? warm / count : 0.5;
    final coolRatio = count > 0 ? cool / count : 0.3;

    // Normalise roughly into 0-1 range so distances are comparable.
    return [
      mean / 255.0,
      stdDev / 128.0,
      warmRatio,
      coolRatio,
    ];
  }

  /// Compares [signature] against up to [sampleSize] of the most recent
  /// existing reports and returns the closest match, if any.
  Future<DuplicateCheckResult> checkForDuplicate(
    List<double> signature, {
    int sampleSize = 30,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(sampleSize)
          .get();

      String? bestId;
      String? bestLocation;
      String? bestType;
      double bestSimilarity = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawSig = data['imageSignature'];

        if (rawSig is! List) continue;

        final existingSignature = rawSig
            .map((e) => (e as num).toDouble())
            .toList(growable: false);

        if (existingSignature.length != signature.length) continue;

        final similarity = _cosineSimilarity(signature, existingSignature);

        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestId = doc.id;
          bestLocation = (data['location'] ?? '').toString();
          bestType = (data['animalType'] ?? '').toString();
        }
      }

      if (bestId != null && bestSimilarity >= _matchThreshold) {
        return DuplicateCheckResult(
          isPossibleDuplicate: true,
          confidence: bestSimilarity,
          success: true,
          matchedReportId: bestId,
          matchedLocation: bestLocation,
          matchedAnimalType: bestType,
        );
      }

      // No match strong enough — still report best similarity found (if
      // any) so the UI can show "looks like a new case".
      return DuplicateCheckResult(
        isPossibleDuplicate: false,
        confidence: bestSimilarity,
        success: true,
      );
    } catch (e) {
      debugPrint('[DuplicateCheckService] error: $e');
      return DuplicateCheckResult.error(
        'Unable to check for duplicate reports.',
      );
    }
  }

  /// Cosine similarity between two equal-length vectors, scaled to 0-1.
  double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;

    final cosine = dot / (math.sqrt(normA) * math.sqrt(normB));

    // Cosine similarity here is already in [0, 1] range since all inputs
    // are non-negative, but clamp defensively.
    return cosine.clamp(0.0, 1.0);
  }
}
