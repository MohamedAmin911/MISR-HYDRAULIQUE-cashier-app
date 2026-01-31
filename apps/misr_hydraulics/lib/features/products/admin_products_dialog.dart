import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:misr_hydraulics/features/products/info_bubbles.dart';
import '../../providers.dart';

class AdminProductDetailsDialog extends ConsumerStatefulWidget {
  final Product product;
  const AdminProductDetailsDialog({super.key, required this.product});

  @override
  ConsumerState<AdminProductDetailsDialog> createState() =>
      _AdminProductDetailsDialogState();
}

class _AdminProductDetailsDialogState
    extends ConsumerState<AdminProductDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.read(productRepositoryProvider);
    final product = widget.product;

    Future<void> showEditDialog({
      required String title,
      required String currentValue,
      required Function(String) onSave,
      bool isNumber = false,
      int maxLines = 1,
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
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              decoration:
                  InputDecoration(labelText: 'القيمة الجديدة لـ $title'),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name, textAlign: TextAlign.right),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showEditDialog(
                title: 'اسم المنتج',
                currentValue: product.name,
                onSave: (val) {
                  if (val.trim().isNotEmpty) {
                    product.name = val.trim();
                    repo.update(product);
                  }
                },
              ),
            ),
          ],
        ),
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
                  value: product.id.toString(),
                  icon: Icons.tag,
                ),
                editable(
                  onEdit: () {
                    showEditDialog(
                      title: 'الفئة',
                      currentValue: product.categoryName,
                      onSave: (val) {
                        product.categoryName = val.trim();
                        repo.update(product);
                      },
                    );
                  },
                  child: InfoBubble(
                    label: 'الفئة',
                    value: product.categoryName,
                    icon: Icons.category_outlined,
                  ),
                ),
                editable(
                  onEdit: () => showEditDialog(
                    title: 'الوصف',
                    currentValue: product.description,
                    maxLines: 3,
                    onSave: (val) {
                      product.description = val.trim();
                      repo.update(product);
                    },
                  ),
                  child: InfoBubble.stacked(
                    label: 'الوصف',
                    value: product.description.isEmpty
                        ? 'لا يوجد وصف'
                        : product.description,
                    icon: Icons.notes_outlined,
                    maxWidth: 520,
                  ),
                ),
                editable(
                  onEdit: () => showEditDialog(
                    title: 'سعر الشراء',
                    currentValue: product.buyPrice.toString(),
                    isNumber: true,
                    onSave: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        product.buyPrice = parsed;
                        repo.update(product);
                      }
                    },
                  ),
                  child: InfoBubble(
                    label: 'سعر الشراء',
                    value: CurrencyFormatter.format(product.buyPrice),
                    icon: Icons.south_west,
                  ),
                ),
                editable(
                  onEdit: () => showEditDialog(
                    title: 'سعر البيع',
                    currentValue: product.sellPrice.toString(),
                    isNumber: true,
                    onSave: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        product.sellPrice = parsed;
                        repo.update(product);
                      }
                    },
                  ),
                  child: InfoBubble(
                    label: 'سعر البيع',
                    value: CurrencyFormatter.format(product.sellPrice),
                    icon: Icons.north_east,
                  ),
                ),
                editable(
                  onEdit: () => showEditDialog(
                    title: 'الكمية',
                    currentValue: product.quantity.toString(),
                    isNumber: true,
                    onSave: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) {
                        product.quantity = parsed;
                        repo.update(product);
                      }
                    },
                  ),
                  child: InfoBubble(
                    label: 'الكمية',
                    value: product.quantity.toString(),
                    icon: Icons.inventory_2_outlined,
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
            child: const Text('إغلاق'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('حذف المنتج'),
                    content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                ),
              );
              if (ok == true) {
                await repo.delete(product.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('حذف المنتج'),
          ),
        ],
      ),
    );
  }
}
