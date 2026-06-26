import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({required this.animal, required this.onTap, super.key});

  final Animal animal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimalImage(type: animal.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                animal.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(status: animal.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 15,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                animal.location,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.text.withValues(
                                        alpha: 0.58,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          animal.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.text.withValues(alpha: 0.64),
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 14,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    animal.type,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.text.withValues(alpha: 0.50),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppTheme.text.withValues(alpha: 0.35),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    animal.dateReported,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.text.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'View Profile',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalImage extends StatelessWidget {
  const _AnimalImage({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.18),
            AppTheme.accent.withValues(alpha: 0.16),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, color: AppTheme.primary, size: 30),
          const SizedBox(height: 4),
          Text(
            type,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
