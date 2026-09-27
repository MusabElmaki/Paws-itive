part of 'feature_pages.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final Map<String, int> _cart = {};

  bool get _isAdmin => widget.profile.role == UserRole.admin;

  bool _checkingOut = false;
  Future<void> _checkout(List<ShopItem> items) async {
    if (_checkingOut) return;
    final cart = items
        .where((item) => (_cart[item.id] ?? 0) > 0)
        .map(
          (item) => <String, dynamic>{
            'itemId': item.id,
            'quantity': _cart[item.id],
          },
        )
        .toList();
    if (cart.isEmpty) return;
    setState(() => _checkingOut = true);
    final paid = await openCheckout(context, kind: 'shop', items: cart);
    if (mounted) {
      setState(() {
        _checkingOut = false;
        if (paid) _cart.clear();
      });
    }
  }

  Future<void> _editItem([ShopItem? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing?.price.toStringAsFixed(2) ?? '',
    );
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final imageController = TextEditingController(
      text: existing?.imageUrl ?? '',
    );
    bool active = existing?.active ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add product' : 'Edit product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price (RM)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active (visible in shop)'),
                  value: active,
                  onChanged: (v) => setLocal(() => active = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    if (nameController.text.trim().isEmpty || price <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a name and a valid price.')),
        );
      }
      return;
    }
    try {
      await FirestoreGateway.instance.upsertShopItem(
        ShopItem(
          id: existing?.id ?? '',
          name: nameController.text.trim(),
          price: price,
          category: categoryController.text.trim(),
          description: descriptionController.text.trim(),
          imageUrl: imageController.text.trim().isEmpty
              ? null
              : imageController.text.trim(),
          active: active,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existing == null ? 'Product added.' : 'Product updated.',
            ),
          ),
        );
      }
    } catch (error) {
      // Surface the real reason (e.g. PERMISSION_DENIED if rules aren't deployed)
      // instead of silently "succeeding".
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ShopItem>>(
      stream: _isAdmin
          ? FirestoreGateway.instance.watchAllShopItems()
          : FirestoreGateway.instance.watchShopItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final items = snapshot.data ?? const [];
        final cartCount = _cart.values.fold<int>(
          0,
          (totalSoFar, value) => totalSoFar + value,
        );
        final tier = rankTierFor(widget.profile.points);
        final subtotal = items.fold<double>(
          0,
          (totalSoFar, item) => totalSoFar + item.price * (_cart[item.id] ?? 0),
        );
        final total = subtotal * (1 - tier.discount);
        return Scaffold(
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => runAction(context, () => _editItem()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PageHeader(
                title: _isAdmin ? 'Manage shop' : 'Shop & cafe',
                subtitle: _isAdmin
                    ? 'Add, edit, activate, or remove products. Sales feed the treasury.'
                    : 'Purchase items that support cat welfare programs.',
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 16),
              if (!_isAdmin) ...[
                Card(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_cafe_outlined,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enjoy great coffee while making a difference. A portion of every purchase '
                            'from our partner coffee shop is contributed to support the care, feeding, '
                            'and welfare of community cats through UTM Paws-itive initiatives.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (snapshot.hasError)
                _ErrorPanel(error: snapshot.error!)
              else if (items.isEmpty)
                EmptyStatePanel(
                  icon: Icons.storefront_outlined,
                  title: 'No products yet',
                  subtitle: _isAdmin
                      ? 'Tap "Add product" to create your first item.'
                      : 'Products will appear once an admin adds them.',
                )
              else if (_isAdmin)
                ...items.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CatThumb(url: item.imageUrl, size: 48),
                      title: Text(
                        '${item.name}${item.active ? '' : '  (hidden)'}',
                      ),
                      subtitle: Text(
                        '${item.category} • RM ${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                runAction(context, () => _editItem(item)),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.error,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete product?'),
                                  content: Text(
                                    'Remove "${item.name}" from the shop?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirestoreGateway.instance.deleteShopItem(
                                  item.id,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                _TierBenefitBanner(tier: tier, points: widget.profile.points),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CatThumb(url: item.imageUrl, size: 56),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(item.category),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.description),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RM ${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(
                                      () => _cart[item.id] =
                                          (_cart[item.id] ?? 0) > 0
                                          ? _cart[item.id]! - 1
                                          : 0,
                                    ),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('${_cart[item.id] ?? 0}'),
                                  IconButton(
                                    onPressed: () => setState(
                                      () => _cart[item.id] =
                                          (_cart[item.id] ?? 0) + 1,
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (cartCount > 0 && tier.discount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CheckoutRow(
                          label: 'Subtotal',
                          value: 'RM ${subtotal.toStringAsFixed(2)}',
                        ),
                        _CheckoutRow(
                          label:
                              '${tier.emoji} ${tier.label} discount (${(tier.discount * 100).toStringAsFixed(0)}%)',
                          value:
                              '- RM ${(subtotal * tier.discount).toStringAsFixed(2)}',
                          highlight: true,
                        ),
                        const Divider(),
                        _CheckoutRow(
                          label: 'Total',
                          value: 'RM ${total.toStringAsFixed(2)}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                FilledButton.icon(
                  onPressed: cartCount == 0 ? null : () => _checkout(items),
                  icon: const Icon(Icons.shopping_cart_checkout_outlined),
                  label: Text(
                    cartCount == 0
                        ? 'Checkout'
                        : 'Checkout ($cartCount items) • RM ${total.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Banner shown at the top of the shop telling the student their current tier,
/// the discount it unlocks, and how many points until the next tier.
class _TierBenefitBanner extends StatelessWidget {
  const _TierBenefitBanner({required this.tier, required this.points});

  final RankTier tier;
  final int points;

  @override
  Widget build(BuildContext context) {
    final isMax = tier == RankTier.platinum;
    final toNext = (tier.nextThreshold - points).clamp(0, tier.nextThreshold);
    final progress = isMax
        ? 1.0
        : ((points - tier.floor) / (tier.nextThreshold - tier.floor)).clamp(
            0.0,
            1.0,
          );
    return Card(
      color: AppTheme.primary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tier.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tier.label} member',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        tier.discount > 0
                            ? 'You get ${(tier.discount * 100).toStringAsFixed(0)}% off every order.'
                            : 'Earn 100 points to unlock 5% off.',
                      ),
                    ],
                  ),
                ),
                Text(
                  '$points pts',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 6),
            Text(
              isMax
                  ? 'Top tier reached — thank you!'
                  : '$toNext points to the next tier',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: highlight ? AppTheme.success : null,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
