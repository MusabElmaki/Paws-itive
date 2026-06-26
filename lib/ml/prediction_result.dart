/// Holds the result of an animal classification prediction.
class PredictionResult {
  /// 'Cat' or 'Other'
  final String label;

  /// Confidence score 0.0 – 1.0
  final double confidence;

  /// Whether the prediction succeeded
  final bool success;

  /// Optional error message when success == false
  final String? errorMessage;

  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.success,
    this.errorMessage,
  });

  /// Confidence expressed as a percentage string, e.g. "97%"
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(0)}%';

  /// Human-readable summary
  @override
  String toString() =>
      success ? '$label ($confidencePercent)' : 'Error: $errorMessage';

  factory PredictionResult.error(String message) => PredictionResult(
        label: 'Unknown',
        confidence: 0.0,
        success: false,
        errorMessage: message,
      );
}
