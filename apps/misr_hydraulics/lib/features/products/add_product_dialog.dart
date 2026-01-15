import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:misr_hydraulics/features/categories/add_category_dialog.dart';
import '../../providers.dart';
import 'products_tab.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final buyCtrl = TextEditingController();
  final craftCtrl = TextEditingController();
  final sellCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '');

  int? selectedCategoryId;
  String? selectedCategoryName;

  bool saving = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesStreamProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة منتج'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'الفئة'),
                        items: categories.asData?.value
                                .map(
                                  (c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: SizedBox(
                                      width: 400,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(c.name),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(189, 244, 67, 54),
                                              minimumSize: const Size(32, 32),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 0),
                                            ),
                                            child: Text('حذف',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            onPressed: () async {
                                              final ok = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) =>
                                                    Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child: AlertDialog(
                                                    title: const Text(
                                                        'حذف التصنيف'),
                                                    content: const Text(
                                                        'هل أنت متأكد من حذف هذا التصنيف'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx, false),
                                                        child:
                                                            const Text('إلغاء'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx, true),
                                                        child:
                                                            const Text('حذف'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                              if (ok == true) {
                                                if (selectedCategoryId ==
                                                    c.id) {
                                                  setState(() {
                                                    selectedCategoryId = null;
                                                    selectedCategoryName = null;
                                                  });
                                                }

                                                await catRepo.delete(c.id);
                                                if (context.mounted) {
                                                  // Navigator.pop(context);
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList() ??
                            [],
                        onChanged: (v) {
                          setState(() {
                            selectedCategoryId = v;
                            selectedCategoryName = categories.asData?.value
                                .firstWhere((e) => e.id == v)
                                .name;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'إضافة فئة',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const AddCategoryDialog(),
                      ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المنتج'),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 2,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Expanded(
                    //   child: TextField(
                    //     controller: craftCtrl,
                    //     keyboardType: TextInputType.number,
                    //     decoration: const InputDecoration(
                    //       labelText: 'المصنعية',
                    //     ),
                    //     textDirection: TextDirection.rtl,
                    //   ),
                    // ),
                    // const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: buyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'سعر الشراء (MRU)',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: sellCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'سعر البيع (MRU)',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  textDirection: TextDirection.rtl,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (selectedCategoryId == null) {
                      setState(() => error = 'يرجى اختيار الفئة');
                      return;
                    }
                    if (nameCtrl.text.trim().isEmpty) {
                      setState(() => error = 'يرجى إدخال اسم المنتج');
                      return;
                    }
                    setState(() {
                      error = null;
                      saving = true;
                    });
                    try {
                      final repo = ref.read(productRepositoryProvider);
                      // In our Hive model, Product has categoryName only (no categoryId).
                      final p = Product()
                        ..name = nameCtrl.text.trim()
                        ..categoryName = selectedCategoryName ?? ''
                        ..description = descCtrl.text.trim()
                        // ..craftPrice =
                        //     double.tryParse(craftCtrl.text.trim()) ?? 0
                        ..sellPrice = double.tryParse(sellCtrl.text.trim()) ?? 0
                        ..buyPrice = double.tryParse(buyCtrl.text.trim()) ?? 0
                        ..quantity = int.tryParse(qtyCtrl.text.trim().isEmpty
                                ? '0'
                                : qtyCtrl.text.trim()) ??
                            0
                        ..createdAt = DateTime.now()
                        ..updatedAt = DateTime.now();

                      await repo.add(p);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => error = 'حدث خطأ: $e');
                    } finally {
                      setState(() => saving = false);
                    }
                  },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
