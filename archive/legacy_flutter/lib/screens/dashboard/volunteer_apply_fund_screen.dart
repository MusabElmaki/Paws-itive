import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Demo-only fund application form. Submits to nowhere (yet) — shows a
/// confirmation snackbar to demonstrate the flow for Sprint 4.
class VolunteerApplyFundScreen extends StatefulWidget {
  const VolunteerApplyFundScreen({super.key});

  @override
  State<VolunteerApplyFundScreen> createState() =>
      _VolunteerApplyFundScreenState();
}

class _VolunteerApplyFundScreenState extends State<VolunteerApplyFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Medical Treatment';

  static const _categories = [
    'Medical Treatment',
    'Food & Supplies',
    'Shelter / Housing',
    'Transport',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fund application submitted for review (demo).'),
        backgroundColor: AppTheme.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Apply for Fund')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Request club funding to cover an animal care expense.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount requested (RM)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason / details',
                hintText: 'Briefly describe the case and why funds are needed',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
