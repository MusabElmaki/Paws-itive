import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class _ClinicEntry {
  const _ClinicEntry(this.name, this.subtitle, this.phone, this.icon);
  final String name;
  final String subtitle;
  final String phone;
  final IconData icon;
}

const _clinics = [
  _ClinicEntry(
    'UTM Veterinary Clinic',
    'On-campus clinic — general checkups & emergencies',
    '+60 7-553 XXXX',
    Icons.local_hospital,
  ),
  _ClinicEntry(
    'Klinik Veterinar Skudai',
    'Nearby off-campus clinic — extended hours',
    '+60 7-556 XXXX',
    Icons.local_hospital,
  ),
  _ClinicEntry(
    'Animal Careline (24hr)',
    'For urgent animal welfare concerns and advice',
    '+60 3-7XXX XXXX',
    Icons.support_agent,
  ),
];

/// Static "Nearby Veterinary Clinics & Careline" page, per stakeholder
/// requirement. Demo-only contact info — no real integration needed yet.
class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Clinics & Careline')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Nearby Veterinary Clinics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Contact these clinics for treatment or advice on injured or sick animals.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.text.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 16),
          ..._clinics.map(
            (clinic) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                  child: Icon(clinic.icon, color: AppTheme.primary),
                ),
                title: Text(
                  clinic.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clinic.subtitle),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: AppTheme.success),
                          const SizedBox(width: 4),
                          Text(
                            clinic.phone,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Phone numbers shown are placeholders for the demo. '
                      'Replace with real clinic contacts before launch.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.text.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
