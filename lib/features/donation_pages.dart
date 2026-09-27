part of 'feature_pages.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  double _selectedAmount = 20;
  final _customController = TextEditingController();
  bool _recording = false;

  static const _presetAmounts = [10.0, 20.0, 50.0, 100.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  double get _amount {
    if (_customController.text.trim().isNotEmpty) {
      return double.tryParse(_customController.text.trim()) ?? 0;
    }
    return _selectedAmount;
  }

  bool get _validAmount => _amount.isFinite && _amount > 0 && _amount <= 100000;

  /// Pay by card through Stripe's hosted checkout.
  Future<void> _payCard() async {
    if (!_validAmount || _recording) return;
    setState(() => _recording = true);
    await openCheckout(context, kind: 'donation', amount: _amount);
    if (mounted) setState(() => _recording = false);
  }

  /// Manual (QR / DuitNow) donation — requires proof of payment.
  Future<void> _confirmManual() async {
    if (!_validAmount) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    final amount = _amount;
    final recorded = await _showDonationEvidenceDialog(
      context,
      profile: widget.profile,
      amount: amount,
    );
    if (recorded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.success,
          content: Text(
            'Thank you! RM ${amount.toStringAsFixed(2)} donation submitted for verification.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    return Scaffold(
      appBar: AppBar(title: const Text('Donate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageHeader(
            title: 'Support our cats',
            subtitle:
                'Pay securely by card, or transfer via DuitNow and upload your receipt.',
            icon: Icons.volunteer_activism,
          ),
          const SizedBox(height: 16),
          Text('Select amount', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetAmounts.map((value) {
              final selected =
                  _selectedAmount == value &&
                  _customController.text.trim().isEmpty;
              return ChoiceChip(
                label: Text('RM ${value.toStringAsFixed(0)}'),
                selected: selected,
                onSelected: (_) => setState(() {
                  _selectedAmount = value;
                  _customController.clear();
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Or enter a custom amount',
              prefixText: 'RM ',
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // --- Option 1: Pay by card (Stripe) ---
          FilledButton.icon(
            onPressed: _recording ? null : _payCard,
            icon: const Icon(Icons.credit_card),
            label: Text('Pay RM ${amount.toStringAsFixed(2)} by card'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Secure card payment powered by Stripe',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'or DuitNow transfer',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),

          if (AppConfig.manualPaymentsConfigured)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _DonationInfoRow(
                      label: AppConfig.bankName,
                      value: AppConfig.accountHolder,
                    ),
                    _DonationInfoRow(
                      label: 'Account',
                      value: AppConfig.accountNumber,
                    ),
                    _DonationInfoRow(
                      label: 'Amount',
                      value: 'RM ${amount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            )
          else
            const Text(
              'Manual transfers are unavailable until the society configures its bank details.',
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _recording || !AppConfig.manualPaymentsConfigured
                ? null
                : _confirmManual,
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text("I've transferred — upload receipt"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'After a DuitNow transfer, upload your receipt (image or PDF) so an admin can verify your donation.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DonationInfoRow extends StatelessWidget {
  const _DonationInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
