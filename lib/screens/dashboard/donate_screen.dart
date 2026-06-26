import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Demo-only donation screen. Does not process real payments — shows a
/// confirmation snackbar to demonstrate the flow for Sprint 4.
class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  double _selectedAmount = 20;
  final _customController = TextEditingController();

  static const _presetAmounts = [10.0, 20.0, 50.0, 100.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _submitDonation() {
    final amount = _customController.text.isNotEmpty
        ? double.tryParse(_customController.text) ?? _selectedAmount
        : _selectedAmount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you! RM ${amount.toStringAsFixed(2)} donation recorded (demo).',
        ),
        backgroundColor: AppTheme.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Donate')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Icon(
              Icons.volunteer_activism,
              size: 64,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Support UTM Paws-itive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Your donation helps feed and treat stray animals on campus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),

          Text('Select amount', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetAmounts.map((amount) {
              final selected = _selectedAmount == amount &&
                  _customController.text.isEmpty;
              return ChoiceChip(
                label: Text('RM ${amount.toStringAsFixed(0)}'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedAmount = amount;
                    _customController.clear();
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          Text('Or enter a custom amount', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(
            controller: _customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: 'RM ',
              hintText: 'e.g. 25',
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _submitDonation,
            icon: const Icon(Icons.favorite),
            label: const Text('Donate Now'),
          ),
        ],
      ),
    );
  }
}
