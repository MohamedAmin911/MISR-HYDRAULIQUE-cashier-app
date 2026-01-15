import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class AddBranchDialog extends ConsumerStatefulWidget {
  const AddBranchDialog({super.key});

  @override
  ConsumerState<AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends ConsumerState<AddBranchDialog> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  String? error;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة فرع'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم الفرع')),
              const SizedBox(height: 8),
              TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف')),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ]
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
                    if (nameCtrl.text.trim().isEmpty) {
                      setState(() => error = 'أدخل اسم الفرع');
                      return;
                    }
                    setState(() {
                      error = null;
                      saving = true;
                    });
                    try {
                      await ref
                          .read(branchRepoProvider)
                          .add(nameCtrl.text.trim(), phoneCtrl.text.trim());
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
