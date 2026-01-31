import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:misr_hydraulics/session/session_provider.dart';
import '../../providers.dart';

class TransactionTile extends ConsumerWidget {
  final SaleTx tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final isAdmin = user?.role.name == 'admin';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('عملية رقم: ${tx.id}'),
        subtitle: Text(
          'التاريخ: ${tx.date.day}/${tx.date.month}/${tx.date.year} • الساعة: ${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')} • '
          'الفرع: ${tx.branchName} • البائع: ${tx.sellerUsername} • العميل: ${tx.customerName.isEmpty ? '-' : tx.customerName} • العناصر: ${tx.items.length}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'الإجمالي: ${CurrencyFormatter.format(tx.totalSell + tx.craftPrice)}'),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () async {
                final bytes =
                    await PdfReceiptBuilder.build(tx: tx, forAdmin: isAdmin);
                await PrintingService.printPdf(bytes,
                    jobName: 'إيصال ELAboudy');
              },
              child: const Text('طباعة'),
            ),
            const SizedBox(width: 8),
            isAdmin
                ? FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    onPressed: () async {
                      bool restock = false;
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: StatefulBuilder(
                            builder: (ctx, setState) => AlertDialog(
                              title: const Text('حذف العملية'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('هل تريد حذف هذه العملية؟'),
                                  const SizedBox(height: 8),
                                  CheckboxListTile(
                                    value: restock,
                                    onChanged: (v) =>
                                        setState(() => restock = v ?? false),
                                    title: const Text('إرجاع الكميات للمخزون'),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ],
                              ),
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
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(txRepoProvider)
                            .delete(tx.id, restock: restock);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حذف العملية')));
                        }
                      }
                    },
                    child: const Text('حذف'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
