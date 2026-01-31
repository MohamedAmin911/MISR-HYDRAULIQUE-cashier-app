import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:core/core.dart';
import '../../providers.dart';
import '../../session/session_provider.dart';
import 'cart_controller.dart';

final productsMapProvider =
    StreamProvider.autoDispose<Map<int, Product>>((ref) {
  return ref.watch(productRepoProvider).watchAll().map(
        (list) => {for (final p in list) p.id: p},
      );
});

class CartTab extends ConsumerStatefulWidget {
  const CartTab({super.key});

  @override
  ConsumerState<CartTab> createState() => _CartTabState();
}

class _CartTabState extends ConsumerState<CartTab> {
  late final TextEditingController _customerCtrl;
  late final TextEditingController _craftPriceCtrl = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _customerCtrl = TextEditingController(text: ref.read(customerNameProvider));
    _customerCtrl.addListener(() {
      ref.read(customerNameProvider.notifier).state = _customerCtrl.text;
    });
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _craftPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final productsMap = ref.watch(productsMapProvider);
    final user = ref.watch(sessionProvider);

    final customerName = ref.watch(customerNameProvider).trim();
    final isCustomerEmpty = customerName.isEmpty;

    final content = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customerCtrl,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم العميل (مطلوب)',
                  prefixIcon: const Icon(Icons.person),
                  // errorText: isCustomerEmpty ? 'اسم العميل مطلوب' : null,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _craftPriceCtrl,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'المصنعية',
                  prefixIcon: const Icon(Icons.construction_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: items.isEmpty || user == null || isCustomerEmpty
                ? null
                : () async {
                    setState(() => _processing = true);
                    try {
                      final repo = ref.read(txRepoProvider);

                      final cartItems = items
                          .map((e) => {
                                'productId': e.productId,
                                'qty': e.quantity,
                              })
                          .toList();

                      final tx = await repo.create(
                        sellerUserId: user.id,
                        sellerUsername: user.username,
                        branchId: user.branchId,
                        branchName: user.branchName,
                        customerName: customerName,
                        cartItems: cartItems,
                        craftPrice: double.tryParse(_craftPriceCtrl.text) ?? 0,
                      );

                      ref.read(cartProvider.notifier).clear();
                      ref.read(customerNameProvider.notifier).state = '';
                      _customerCtrl.clear();
                      _craftPriceCtrl.clear();

                      final bytes = await PdfReceiptBuilder.build(
                        tx: tx,
                        forAdmin: true,
                      );

                      if (mounted) setState(() => _processing = false);

                      try {
                        if (kIsWeb) {
                          await PrintingService.printPdf(
                            bytes,
                            jobName: 'إيصال ELAboudy',
                          );
                        } else {
                          await PrintingService.saveAndOpenPdf(
                            bytes,
                            filename: 'ELAboudy_Receipt_${tx.id}.pdf',
                          );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تمت العملية بنجاح، وتم فتح/طباعة الإيصال',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تعذرت الطباعة تلقائيًا: $e'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) setState(() => _processing = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل إتمام العملية: $e')),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.check),
            label: const Text('إتمام العملية'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('السلة فارغة'))
              : productsMap.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('خطأ: $e')),
                  data: (map) {
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final it = items[i];
                        final p = map[it.productId];
                        final maxAvail = p?.quantity ?? it.quantity;
                        return Card(
                          child: ListTile(
                            title: Text(it.productName),
                            subtitle: Text(
                              'السعر: ${CurrencyFormatter.format(it.sellPrice)}',
                            ),
                            leading: IconButton(
                              tooltip: 'حذف',
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .remove(it.productId),
                              icon: const Icon(Icons.delete_outline),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .increment(it.productId,
                                          maxAvailable: maxAvail),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                                Text(it.quantity.toString()),
                                IconButton(
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .decrement(it.productId),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'الإجمالي: ${CurrencyFormatter.format(total)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: content),
          if (_processing)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'جارٍ تجهيز الإيصال...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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
