import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:misr_hydraulics/features/analytics/add_expense_dialog.dart';
import '../../providers.dart';

final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);
final selectedMonthProvider = StateProvider<int?>((ref) => null);
final selectedDayProvider = StateProvider<int?>((ref) => null);

final txsStreamProvider = StreamProvider.autoDispose<List<SaleTx>>((ref) {
  return ref.watch(txRepoProvider).watchAllDesc();
});
final expensesStreamProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return ref.watch(expenseRepoProvider).watchAll();
});
final productsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(productRepoProvider).watchAll().map((l) => l.length);
});

final analyticsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);
  final day = ref.watch(selectedDayProvider);

  final txs = ref
      .watch(txsStreamProvider)
      .maybeWhen(data: (d) => d, orElse: () => const <SaleTx>[]);
  final exs = ref
      .watch(expensesStreamProvider)
      .maybeWhen(data: (d) => d, orElse: () => const <Expense>[]);

  double totalRevenue = 0;
  double totalCost = 0;
  int txCount = 0;
  double craftProfit = 0;

  for (final t in txs) {
    if (t.date.year != year) continue;
    if (month != null && t.date.month != month) continue;
    if (day != null && t.date.day != day) continue;

    txCount++;
    for (final it in t.items) {
      final unitTotal = it.sellPriceAtSale;
      final buy = it.buyPriceAtSale;

      totalRevenue += (unitTotal * it.quantity);
      totalCost += (buy! * it.quantity);
    }
    craftProfit += t.craftPrice;
  }
  totalRevenue += craftProfit;

  final grossProfit = totalRevenue - totalCost;

  double expensesTotal = 0;
  final filteredExpenses = <Expense>[];
  for (final e in exs) {
    if (e.date.year == year) {
      if (month != null && e.date.month != month) continue;
      if (day != null && e.date.day != day) continue;

      expensesTotal += e.amount;
      filteredExpenses.add(e);
    }
  }

  final netProfit = grossProfit - expensesTotal;

  return {
    'year': year,
    'revenue': totalRevenue,
    'cost': totalCost,
    'gross': grossProfit,
    'expenses': expensesTotal,
    'net': netProfit,
    'txCount': txCount,
    'yearExpenses': filteredExpenses,
  };
});

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    final productsCount = ref
        .watch(productsCountProvider)
        .maybeWhen(data: (v) => v, orElse: () => 0);
    final txs = ref
        .watch(txsStreamProvider)
        .maybeWhen(data: (d) => d, orElse: () => const <SaleTx>[]);
    final years = _collectYears(txs);

    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<int>(
                  value: data['year'] as int,
                  items: years
                      .map((y) => DropdownMenuItem<int>(
                          value: y, child: Text('سنة $y')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedYearProvider.notifier).state = v;
                    }
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: selectedMonth,
                  hint: const Text('الشهر'),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('كل الشهور')),
                    ...List.generate(12, (index) {
                      final m = index + 1;
                      return DropdownMenuItem<int?>(
                          value: m, child: Text('شهر $m'));
                    }),
                  ],
                  onChanged: (v) {
                    ref.read(selectedMonthProvider.notifier).state = v;
                    if (v == null) {
                      ref.read(selectedDayProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: selectedDay,
                  hint: const Text('اليوم'),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('كل الأيام')),
                    ...List.generate(31, (index) {
                      final d = index + 1;
                      return DropdownMenuItem<int?>(
                          value: d, child: Text('يوم $d'));
                    }),
                  ],
                  onChanged: (v) {
                    ref.read(selectedDayProvider.notifier).state = v;
                  },
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const AddExpenseDialog()),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة مصروف'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metricCard(context, 'عدد المنتجات', productsCount.toString(),
                    cs.secondary),
                _metricCard(context, 'عدد العمليات',
                    (data['txCount'] as int).toString(), cs.secondary),
                _metricCard(
                    context,
                    'إجمالي المبيعات',
                    CurrencyFormatter.format(data['revenue'] as double),
                    Colors.brown),
                _metricCard(
                    context,
                    'إجمالي المصروفات',
                    CurrencyFormatter.format(data['expenses'] as double),
                    Colors.red),
                _metricCard(
                    context,
                    'الربح الصافي',
                    CurrencyFormatter.format(data['net'] as double),
                    Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ExpensesList(
                  yearExpenses: (data['yearExpenses'] as List<Expense>)),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _collectYears(List<SaleTx> txs) {
    final set = <int>{DateTime.now().year};
    for (final t in txs) {
      set.add(t.date.year);
    }
    final l = set.toList();
    l.sort((a, b) => b.compareTo(a));
    return l;
  }

  Widget _metricCard(
      BuildContext context, String title, String value, Color color) {
    return SizedBox(
      width: 290,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: color,
              width: 3,
            )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensesList extends ConsumerWidget {
  const _ExpensesList({required this.yearExpenses});
  final List<Expense> yearExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (yearExpenses.isEmpty) {
      return const Center(child: Text('لا توجد بيانات لهذه الفترة'));
    }
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border:
            Border.all(color: const Color.fromARGB(62, 218, 140, 31), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        itemCount: yearExpenses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = yearExpenses[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(e.title),
              subtitle:
                  Text('التاريخ: ${e.date.day}/${e.date.month}/${e.date.year}'),
              trailing: Text(CurrencyFormatter.format(e.amount)),
              onLongPress: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('حذف المصروف'),
                      content: const Text('هل تريد حذف هذا المصروف؟'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('إلغاء')),
                        FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('حذف')),
                      ],
                    ),
                  ),
                );
                if (ok == true) {
                  await ref.read(expenseRepoProvider).delete(e.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف المصروف')));
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
