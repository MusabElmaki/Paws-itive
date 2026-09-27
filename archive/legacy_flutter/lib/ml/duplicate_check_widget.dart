// lib/ml/duplicate_check_widget.dart
//
// Displays the "has this cat been reported before?" result below the
// uploaded photo on the Report Animal screen. Three states: loading,
// possible-duplicate found, and no-match (new case).

import 'package:flutter/material.dart';

import 'duplicate_check_result.dart';
import '../theme/app_theme.dart';

class DuplicateCheckWidget extends StatelessWidget {
  const DuplicateCheckWidget({
    super.key,
    required this.isLoading,
    this.result,
  });

  final bool isLoading;
  final DuplicateCheckResult? result;

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
      key: const ValueKey('dup-loading'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecor(
        AppTheme.primary.withValues(alpha: 0.08),
        AppTheme.primary.withValues(alpha: 0.20),
      ),
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
            'Checking if this cat was reported before…',
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
        key: const ValueKey('dup-error'),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _cardDecor(
          AppTheme.error.withValues(alpha: 0.08),
          AppTheme.error.withValues(alpha: 0.22),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                r.errorMessage ?? 'Unable to check for duplicate reports.',
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

    if (r.isPossibleDuplicate) {
      return Container(
        key: const ValueKey('dup-found'),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecor(
          AppTheme.accent.withValues(alpha: 0.14),
          AppTheme.accent.withValues(alpha: 0.34),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 18, color: Color(0xFF8A5E20)),
                const SizedBox(width: 8),
                Text(
                  'Possible Duplicate (Demo AI Check)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF8A5E20),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'This cat may already have been reported '
              '(${r.confidencePercent} similarity) near '
              '"${r.matchedLocation ?? 'an earlier location'}".',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.text,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'You can still submit — this is just a heads-up so volunteers '
              "don't duplicate the same case.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      );
    }

    // No match — looks like a new case.
    return Container(
      key: const ValueKey('dup-new'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecor(
        AppTheme.success.withValues(alpha: 0.10),
        AppTheme.success.withValues(alpha: 0.26),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No matching report found — this looks like a new case.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
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
}
