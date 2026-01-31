import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:misr_hydraulics/features/products/info_bubbles.dart';
import '../cart/cart_controller.dart';
// import '../../providers.dart';

class ProductDialog extends ConsumerStatefulWidget {
  final Product product;
  const ProductDialog({super.key, required this.product});

  @override
  ConsumerState<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<ProductDialog> {
  late TextEditingController qtyCtrl;
  int? qty = 1;

  @override
  void initState() {
    super.initState();
    qtyCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> showEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) async {
    final ctrl = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تعديل $title'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'القيمة الجديدة لـ $title'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                onSave(ctrl.text);
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget editable({
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        child,
        IconButton(
          icon: const Icon(Icons.edit,
              size: 16, color: Color.fromARGB(255, 210, 128, 28)),
          tooltip: 'تعديل',
          onPressed: onEdit,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final maxQty = p.quantity;
    // final repo = ref.read(productRepositoryProvider);

    // Validate Input Logic
    bool isValid = true;
    String? errorText;

    if (qty == null || qty! <= 0) {
      isValid = false;
      errorText = 'مطلوب';
    } else if (maxQty > 0 && qty! > maxQty) {
      isValid = false;
      errorText = 'المتاح: $maxQty';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(p.name, textAlign: TextAlign.right),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InfoBubble(
                  label: 'المعرف',
                  value: p.id.toString(),
                  icon: Icons.tag_outlined,
                ),
                InfoBubble(
                  label: 'الفئة',
                  value: p.categoryName,
                  icon: Icons.category_outlined,
                ),
                if (p.description.isNotEmpty)
                  InfoBubble.stacked(
                    label: 'الوصف',
                    value: p.description,
                    icon: Icons.notes_outlined,
                    // FIX: Must be smaller than SizedBox width (560) - padding
                    maxWidth: 520,
                  ),
                InfoBubble(
                  label: 'السعر',
                  value: CurrencyFormatter.format(p.sellPrice),
                  icon: Icons.sell_outlined,
                )

                // editable(
                //   onEdit: () => showEditDialog(
                //     title: 'السعر',
                //     currentValue: p.sellPrice.toString(),
                //     onSave: (val) {
                //       final parsed = double.tryParse(val);
                //       if (parsed != null) {
                //         p.sellPrice = parsed;
                //         repo.update(p);
                //       }
                //     },
                //   ),
                //   child: InfoBubble(
                //     label: 'السعر',
                //     value: CurrencyFormatter.format(p.sellPrice),
                //     icon: Icons.sell_outlined,
                //   ),
                // )
                ,
                InfoBubble(
                  label: 'المتوفر',
                  value: maxQty.toString(),
                  icon: Icons.inventory_2_outlined,
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الكمية المطلوبة',
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onChanged: (v) {
                      setState(() {
                        qty = int.tryParse(v);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: (p.quantity == 0 || !isValid)
                ? null
                : () {
                    final unitTotal = p.sellPrice + p.craftPrice;
                    ref.read(cartProvider.notifier).addOrUpdate(
                          productId: p.id,
                          name: p.name,
                          sellPrice: unitTotal,
                          craftPrice: p.craftPrice,
                          addQuantity: qty!,
                          maxAvailable: p.quantity,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت الإضافة إلى السلة')),
                      );
                    }
                  },
            child: const Text('إضافة إلى السلة'),
          ),
        ],
      ),
    );
  }
}
