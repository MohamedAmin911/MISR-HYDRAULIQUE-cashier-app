import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  DateTime date = DateTime.now();
  String? error;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة مصروف'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'العنوان')),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'القيمة (MRU)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('التاريخ:'),
                  const SizedBox(width: 8),
                  Text('${date.day}/${date.month}/${date.year}',
                      style: TextStyle(color: cs.primary)),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                        locale: const Locale('ar'),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                    icon: const Icon(Icons.date_range),
                    label: const Text('اختر التاريخ'),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    final title = titleCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim());
                    if (title.isEmpty || amount == null) {
                      setState(() => error = 'أدخل العنوان والقيمة بشكل صحيح');
                      return;
                    }
                    setState(() {
                      error = null;
                      saving = true;
                    });
                    try {
                      await ref
                          .read(expenseRepoProvider)
                          .add(title: title, amount: amount, date: date);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => error = '$e');
                    } finally {
                      setState(() => saving = false);
                    }
                  },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
