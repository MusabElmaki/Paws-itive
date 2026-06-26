import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class _Transaction {
  const _Transaction(this.title, this.date, this.amount, this.isCredit);
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
}

const _transactions = [
  _Transaction('Donation - Tan Mei Ling', '20 Jun 2026', 50.00, true),
  _Transaction('Vet bill - Case #102', '18 Jun 2026', 120.00, false),
  _Transaction('Donation - Faris Rahman', '15 Jun 2026', 30.00, true),
  _Transaction('Cat food supplies', '12 Jun 2026', 85.50, false),
  _Transaction('Club fund grant', '01 Jun 2026', 500.00, true),
];

/// Demo-only screen: hardcoded treasury balance and transactions for
/// Sprint 4 presentation. Not connected to a real payments backend.
class AdminTreasuryScreen extends StatelessWidget {
  const AdminTreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Treasury')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: AppTheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RM 2,480.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._transactions.map(
            (tx) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.isCredit
                      ? AppTheme.success.withValues(alpha: 0.14)
                      : AppTheme.error.withValues(alpha: 0.12),
                  child: Icon(
                    tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: tx.isCredit ? AppTheme.success : AppTheme.error,
                  ),
                ),
                title: Text(tx.title),
                subtitle: Text(tx.date),
                trailing: Text(
                  '${tx.isCredit ? '+' : '-'}RM ${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tx.isCredit ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
