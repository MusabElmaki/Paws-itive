import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

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

  /// 0..1 visual similarity score, not an identity probability
  /// (the similarity to the closest existing record).
  final double confidence;

  /// Same value expressed as a 0–100 percentage for display.
  int get likelihoodPercent => (confidence * 100).round();

  final String message;
  final List<double> signature;
  final String? existingCatId;
  final String? existingCatName;
  final String? existingLocationName;
}

/// Lightweight perceptual cat matcher.
///
/// It decodes the actual image pixels (the old version mistakenly ran stats on
/// the compressed JPEG bytes, so its scores were meaningless) and builds a
/// 128-value signature:
///   * a 64-bin RGB colour histogram (captures fur / coat colour), and
///   * a 64-value 8×8 greyscale thumbnail (captures coarse markings/structure).
/// Each half is L2-normalised, so cosine similarity between two signatures is a
/// balanced blend of "same colours" and "same pattern" — a graded 0..1
/// similarity score; it is not a calibrated probability.
class CatMatchingService {
  CatMatchingService._();

  static final instance = CatMatchingService._();

  /// Advisory threshold only. Linking requires a staff review.
  static const double _reviewThreshold = 0.60;

  static const int _binsPerChannel = 4; // 4*4*4 = 64-bin colour histogram
  static const int _structSize = 8; // 8x8 = 64 greyscale structure values

  List<double> buildSignature(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return List<double>.filled(
        _binsPerChannel * _binsPerChannel * _binsPerChannel +
            _structSize * _structSize,
        0,
      );
    }

    // --- Colour histogram on a 64x64 resample ---
    final small = img.copyResize(decoded, width: 64, height: 64);
    final hist = List<double>.filled(
      _binsPerChannel * _binsPerChannel * _binsPerChannel,
      0,
    );
    for (var y = 0; y < small.height; y++) {
      for (var x = 0; x < small.width; x++) {
        final p = small.getPixel(x, y);
        final rb = (p.r.toInt().clamp(0, 255) * _binsPerChannel) ~/ 256;
        final gb = (p.g.toInt().clamp(0, 255) * _binsPerChannel) ~/ 256;
        final bb = (p.b.toInt().clamp(0, 255) * _binsPerChannel) ~/ 256;
        hist[(rb * _binsPerChannel + gb) * _binsPerChannel + bb] += 1;
      }
    }
    _l2Normalise(hist);

    // --- Coarse greyscale structure on an 8x8 resample ---
    final tiny = img.copyResize(
      decoded,
      width: _structSize,
      height: _structSize,
    );
    final struct = List<double>.filled(_structSize * _structSize, 0);
    var sum = 0.0;
    for (var y = 0; y < tiny.height; y++) {
      for (var x = 0; x < tiny.width; x++) {
        final p = tiny.getPixel(x, y);
        final gray = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        struct[y * _structSize + x] = gray;
        sum += gray;
      }
    }
    // Mean-subtract so overall brightness doesn't dominate, then L2-normalise.
    final mean = struct.isEmpty ? 0.0 : sum / struct.length;
    for (var i = 0; i < struct.length; i++) {
      struct[i] -= mean;
    }
    _l2Normalise(struct);

    return [...hist, ...struct];
  }

  Future<CatMatchResult> match(Uint8List bytes) async {
    final signature = buildSignature(bytes);
    String? bestId;
    String? bestName;
    String? bestLocation;
    double bestScore = 0;
    QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('cats')
          .orderBy(FieldPath.documentId)
          .limit(200);
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }
      final page = await query.get();
      for (final doc in page.docs) {
        final data = doc.data();
        if (data['archived'] == true || data['linkedTo'] != null) continue;
        final raw = data['imageSignature'];
        if (raw is! List ||
            raw.length != signature.length ||
            raw.any((v) => v is! num || !v.isFinite)) {
          continue;
        }
        final existing = raw
            .map((v) => (v as num).toDouble())
            .toList(growable: false);
        final score = _similarity(signature, existing);
        if (score > bestScore) {
          bestScore = score;
          bestId = doc.id;
          bestName = data['name']?.toString();
          bestLocation = data['currentLocationName']?.toString();
        }
      }
      if (page.docs.length < 200) break;
      cursor = page.docs.last;
    }

    final suggested = bestId != null && bestScore >= _reviewThreshold;
    return CatMatchResult(
      isMatch: suggested,
      confidence: bestScore,
      message: suggested
          ? 'Similar photo found. A volunteer will review the suggestion.'
          : 'New sighting saved.',
      signature: signature,
      existingCatId: suggested ? bestId : null,
      existingCatName: bestName,
      existingLocationName: bestLocation,
    );
  }

  void _l2Normalise(List<double> v) {
    var norm = 0.0;
    for (final x in v) {
      norm += x * x;
    }
    norm = math.sqrt(norm);
    if (norm == 0) return;
    for (var i = 0; i < v.length; i++) {
      v[i] /= norm;
    }
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
