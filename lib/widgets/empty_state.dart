import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    this.title = 'No animal reports yet',
    this.message = 'Be the first to report a stray animal in UTM',
    this.buttonLabel = 'Report Animal',
    this.onPressed,
    super.key,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 44, color: AppTheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.text.withValues(alpha: 0.62),
              ),
            ),
            if (onPressed != null) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.pets),
                label: Text(buttonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
