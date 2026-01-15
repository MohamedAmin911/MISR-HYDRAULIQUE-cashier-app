import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final nameCtrl = TextEditingController();
  String? error;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة فئة'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'اسم الفئة'),
            textDirection: TextDirection.rtl,
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
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setState(() => error = 'أدخل اسم الفئة');
                      return;
                    }
                    setState(() {
                      error = null;
                      saving = true;
                    });
                    try {
                      await ref.read(categoryRepositoryProvider).add(name);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => error = '$e');
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
