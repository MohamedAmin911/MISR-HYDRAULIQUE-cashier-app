import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:misr_hydraulics/features/categories/add_category_dialog.dart';
import 'package:misr_hydraulics/features/loading.dart';
import 'package:misr_hydraulics/features/products/admin_products_dialog.dart';
import 'package:misr_hydraulics/features/products/info_bubbles.dart';
import '../../providers.dart';
import '../../session/session_provider.dart';
import 'add_product_dialog.dart';
import 'product_dialog.dart';

final productQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchAll();
});

final categoriesStreamProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

class ProductsTab extends ConsumerWidget {
  const ProductsTab({super.key});

  void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم النسخ')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);
    final query = ref.watch(productQueryProvider);
    final user = ref.watch(sessionProvider);
    final isAdmin = user?.role.name == 'admin';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AddProductDialog(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: (v) => ref
                          .read(productQueryProvider.notifier)
                          .state = v.trim(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'ابحث بالاسم أو المعرف أو الصنف',
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                tooltip: 'مسح',
                                onPressed: () => ref
                                    .read(productQueryProvider.notifier)
                                    .state = '',
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isAdmin)
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const AddCategoryDialog()),
                        icon: const Icon(Icons.category_outlined),
                        label: const Text('إضافة فئة'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: products.when(
                  loading: () => const Loading(),
                  error: (e, st) => Center(child: Text('خطأ: $e')),
                  data: (list) {
                    final q = query.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? list
                        : list.where((p) {
                            final name = p.name.toLowerCase();
                            final id = p.id.toString();
                            final category = p.categoryName.toLowerCase();
                            return name.contains(q) ||
                                id.contains(q) ||
                                category.contains(q);
                          }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                          child: Text(q.isEmpty
                              ? 'لا توجد منتجات بعد'
                              : 'لا توجد نتائج مطابقة لـ "$q"'));
                    }

                    final info = Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text('النتائج: ${filtered.length} / ${list.length}'),
                    );

                    final colCount =
                        (MediaQuery.of(context).size.width ~/ 420).clamp(1, 4);
                    return Column(
                      children: [
                        info,
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: colCount,
                              childAspectRatio: 2.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    if (isAdmin) {
                                      showDialog(
                                          context: context,
                                          builder: (_) =>
                                              AdminProductDetailsDialog(
                                                  product: p));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (_) =>
                                              ProductDialog(product: p));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(.10),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.inventory_2_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              p.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                            const SizedBox(width: 20),
                                            if (p.id >= 0)
                                              Text(
                                                p.id.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            if (isAdmin && p.id >= 0) ...[
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () => copy(
                                                    context, p.id.toString()),
                                                icon: const Icon(Icons.copy),
                                                tooltip: 'نسخ المعرف',
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.start,
                                          children: [
                                            InfoBubble(
                                                label: 'الفئة',
                                                value: p.categoryName,
                                                icon: Icons.category_outlined),
                                            // InfoBubble(
                                            //     label: 'المصنعية',
                                            //     value: CurrencyFormatter.format(
                                            //         p.craftPrice),
                                            //     icon: Icons
                                            //         .build_circle_outlined),
                                            InfoBubble(
                                                label: 'سعر الشراء',
                                                value: CurrencyFormatter.format(
                                                    p.buyPrice),
                                                icon: Icons.south_west),
                                            InfoBubble(
                                                label: 'سعر البيع',
                                                value: CurrencyFormatter.format(
                                                    p.sellPrice),
                                                icon: Icons.sell_outlined),
                                            InfoBubble(
                                                label: 'الكمية',
                                                value: p.quantity.toString(),
                                                icon:
                                                    Icons.inventory_2_rounded),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
