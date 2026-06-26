import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Placeholder map preview — no maps package is wired up yet (e.g.
/// google_maps_flutter), per Sprint 4 scope. This shows a styled
/// placeholder with pinned sample locations so the UI flow can be
/// demonstrated, with real map integration left for a future sprint.
class VolunteerMapPreviewScreen extends StatelessWidget {
  const VolunteerMapPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Map Preview')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Faux map grid background
                    CustomPaint(
                      size: Size.infinite,
                      painter: _GridPainter(),
                    ),

                    _pin(top: 80, left: 60, color: AppTheme.error),
                    _pin(top: 160, left: 200, color: AppTheme.error),
                    _pin(top: 240, left: 110, color: AppTheme.accent),
                    _pin(top: 320, left: 240, color: AppTheme.error),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Map integration coming soon',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This is a placeholder preview. Pins show approximate '
                        'locations of recent animal reports around campus.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin({required double top, required double left, required Color color}) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(Icons.location_on, color: color, size: 36),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    const step = 36.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
