import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../../providers.dart';

class AddUserToBranchDialog extends ConsumerStatefulWidget {
  final Branch branch;
  const AddUserToBranchDialog({super.key, required this.branch});

  @override
  ConsumerState<AddUserToBranchDialog> createState() =>
      _AddUserToBranchDialogState();
}

class _AddUserToBranchDialogState extends ConsumerState<AddUserToBranchDialog> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  UserRole role = UserRole.seller;

  bool saving = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final b = widget.branch;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('إضافة مستخدم للفرع: ${b.name}'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: userCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم')),
              const SizedBox(height: 12),
              TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: role,
                items: const [
                  DropdownMenuItem(value: UserRole.seller, child: Text('بائع')),
                  DropdownMenuItem(value: UserRole.admin, child: Text('مسؤول')),
                ],
                onChanged: (v) => setState(() => role = v ?? UserRole.seller),
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
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
                    final un = userCtrl.text.trim();
                    final pw = passCtrl.text;
                    if (un.isEmpty || pw.isEmpty) {
                      setState(() => error = 'أدخل اسم المستخدم وكلمة المرور');
                      return;
                    }
                    setState(() {
                      error = null;
                      saving = true;
                    });
                    try {
                      final existing =
                          await ref.read(userRepoProvider).watchAll().first;
                      if (existing.any((u) =>
                          u.username.toLowerCase() == un.toLowerCase())) {
                        setState(() => error = 'اسم المستخدم موجود بالفعل');
                        setState(() => saving = false);
                        return;
                      }
                      await ref.read(userRepoProvider).add(
                            username: un,
                            password: pw,
                            role: role,
                            branchId: b.id,
                            branchName: b.name,
                            phone: b.phone,
                          );
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
