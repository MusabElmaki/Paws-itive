// lib/ml/prediction_widget.dart
//
// Displays the ML prediction result below the uploaded image.
// Three states: loading, success, error.

import 'package:flutter/material.dart';

import '../ml/prediction_result.dart';
import '../theme/app_theme.dart';

/// Shows the current ML prediction state below the animal photo picker.
///
/// Pass [isLoading] = true while inference is running.
/// Pass [result] once inference completes (may be null before first run).
class PredictionWidget extends StatelessWidget {
  const PredictionWidget({
    super.key,
    required this.isLoading,
    this.result,
  });

  final bool isLoading;
  final PredictionResult? result;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && result == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading ? _buildLoading(context) : _buildResult(context),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Container(
      key: const ValueKey('loading'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecor(AppTheme.primary.withValues(alpha: 0.08),
          AppTheme.primary.withValues(alpha: 0.20)),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Analysing image…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  // ── Result / Error ────────────────────────────────────────────────────────

  Widget _buildResult(BuildContext context) {
    final r = result!;

    if (!r.success) {
      return Container(
        key: const ValueKey('error'),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _cardDecor(AppTheme.error.withValues(alpha: 0.08),
            AppTheme.error.withValues(alpha: 0.22)),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppTheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                r.errorMessage ?? 'Unable to identify the animal.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    // Success
    final icon = _animalIcon(r.label);
    final conf = r.confidence;
    final barColor = conf >= 0.75
        ? AppTheme.success
        : conf >= 0.50
            ? AppTheme.accent
            : AppTheme.secondary;

    return Container(
      key: const ValueKey('result'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(AppTheme.primary.withValues(alpha: 0.07),
          AppTheme.primary.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'AI Prediction',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Animal type row
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Animal Type',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color:
                                      AppTheme.text.withValues(alpha: 0.55)),
                        ),
                        Text(
                          r.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppTheme.text,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color:
                                      AppTheme.text.withValues(alpha: 0.55)),
                        ),
                        Text(
                          r.confidencePercent,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: barColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Confidence bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: conf,
                        backgroundColor:
                            AppTheme.border.withValues(alpha: 0.6),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tip when confidence is low
          if (conf < 0.55) ...[
            const SizedBox(height: 10),
            Text(
              'Low confidence – please verify the animal type manually.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDecor(Color fill, Color border) => BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      );

  String _animalIcon(String label) {
    switch (label) {
      case 'Cat':
        return '🐱';
      default:
        return '🐾';
    }
  }
}
