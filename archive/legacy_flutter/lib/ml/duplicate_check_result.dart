/// Holds the result of a "has this cat been reported before?" check.
///
/// DEMO NOTE: This is a presentation-only heuristic, not a real image
/// similarity / face-recognition model. It compares a cheap pixel
/// signature of the new photo against signatures already stored on
/// existing reports in Firestore, and flags a "possible match" when they
/// are close enough. Good enough to demonstrate the *workflow* the
/// stakeholder asked for; not production-grade duplicate detection.
class DuplicateCheckResult {
  const DuplicateCheckResult({
    required this.isPossibleDuplicate,
    required this.confidence,
    required this.success,
    this.matchedReportId,
    this.matchedLocation,
    this.matchedAnimalType,
    this.errorMessage,
  });

  /// True if an existing report looks similar enough to flag.
  final bool isPossibleDuplicate;

  /// How similar the closest match is, 0.0 - 1.0.
  final double confidence;

  /// Whether the check ran successfully.
  final bool success;

  /// Firestore doc id of the closest matching existing report, if any.
  final String? matchedReportId;

  /// Location text of the matched report, for display.
  final String? matchedLocation;

  /// Animal type of the matched report, for display.
  final String? matchedAnimalType;

  /// Optional error message when success == false.
  final String? errorMessage;

  /// Confidence expressed as a percentage string, e.g. "82%"
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  factory DuplicateCheckResult.error(String message) =>
      DuplicateCheckResult(
        isPossibleDuplicate: false,
        confidence: 0.0,
        success: false,
        errorMessage: message,
      );

  factory DuplicateCheckResult.noMatch() => const DuplicateCheckResult(
        isPossibleDuplicate: false,
        confidence: 0.0,
        success: true,
      );
}
