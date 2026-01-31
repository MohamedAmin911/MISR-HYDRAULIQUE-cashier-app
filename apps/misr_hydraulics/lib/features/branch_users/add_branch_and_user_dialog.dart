import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../../providers.dart';

class AddBranchAndUserDialog extends ConsumerStatefulWidget {
  const AddBranchAndUserDialog({super.key});

  @override
  ConsumerState<AddBranchAndUserDialog> createState() =>
      _AddBranchAndUserDialogState();
}

class _AddBranchAndUserDialogState
    extends ConsumerState<AddBranchAndUserDialog> {
  final branchCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  UserRole role = UserRole.seller;

  bool saving = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة فرع + مستخدم'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: branchCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الفرع')),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف')),
                const Divider(height: 24),
                TextField(
                    controller: userCtrl,
                    decoration:
                        const InputDecoration(labelText: 'اسم المستخدم')),
                const SizedBox(height: 12),
                TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                        value: UserRole.seller, child: Text('بائع')),
                    DropdownMenuItem(
                        value: UserRole.admin, child: Text('مسؤول')),
                  ],
                  onChanged: (v) => setState(() => role = v ?? UserRole.seller),
                  decoration: const InputDecoration(labelText: 'الدور'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
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
                    final bn = branchCtrl.text.trim();
                    final ph = phoneCtrl.text.trim();
                    final un = userCtrl.text.trim();
                    final pw = passCtrl.text;
                    if (bn.isEmpty || un.isEmpty || pw.isEmpty || ph.isEmpty) {
                      setState(() => error =
                          'أدخل اسم الفرع واسم المستخدم وكلمة المرور ورقم الهاتف');
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

                      final branchId =
                          await ref.read(branchRepoProvider).add(bn, ph);
                      await ref.read(userRepoProvider).add(
                            username: un,
                            password: pw,
                            role: role,
                            branchId: branchId,
                            branchName: bn,
                            phone: ph,
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
