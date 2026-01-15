import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers.dart';
import 'transaction_tile.dart';

enum TxSort { desc, asc }

final txSortProvider = StateProvider<TxSort>((ref) => TxSort.desc);

// Search query
final txQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// Base stream (newest first), then in UI we sort/filter based on state
final txsSortedProvider = StreamProvider.autoDispose<List<SaleTx>>((ref) {
  final sort = ref.watch(txSortProvider);
  return ref.watch(txRepoProvider).watchAllDesc().map((list) {
    if (sort == TxSort.desc) return list;
    final copy = [...list];
    copy.sort((a, b) => a.date.compareTo(b.date)); // ascending
    return copy;
  });
});

class TransactionsTab extends ConsumerWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(txsSortedProvider);
    final sort = ref.watch(txSortProvider);
    final query = ref.watch(txQueryProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              onChanged: (v) =>
                  ref.read(txQueryProvider.notifier).state = v.trim(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText:
                    'ابحث برقم الإيصال أو اسم العميل أو اسم البائع أو اسم الفرع',
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        tooltip: 'مسح',
                        onPressed: () =>
                            ref.read(txQueryProvider.notifier).state = '',
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),

            // Sort controls
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<TxSort>(
                segments: const [
                  ButtonSegment(
                    value: TxSort.desc,
                    label: Text('الأحدث أولاً'),
                    icon: Icon(Icons.south),
                  ),
                  ButtonSegment(
                    value: TxSort.asc,
                    label: Text('الأقدم أولاً'),
                    icon: Icon(Icons.north),
                  ),
                ],
                selected: {sort},
                onSelectionChanged: (s) {
                  ref.read(txSortProvider.notifier).state = s.first;
                },
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: txs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('خطأ: $e')),
                data: (list) {
                  // Filter by ID / customerName / sellerUsername / branchName
                  final q = query.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? list
                      : list.where((t) {
                          final id = t.id.toString();
                          final customer = t.customerName.toLowerCase();
                          final seller = t.sellerUsername.toLowerCase();
                          final branch = t.branchName.toLowerCase();
                          return id.contains(q) ||
                              customer.contains(q) ||
                              seller.contains(q) ||
                              branch.contains(q);
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        query.isEmpty
                            ? 'لا توجد عمليات بعد'
                            : 'لا توجد نتائج مطابقة لـ "$query"',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        TransactionTile(tx: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
