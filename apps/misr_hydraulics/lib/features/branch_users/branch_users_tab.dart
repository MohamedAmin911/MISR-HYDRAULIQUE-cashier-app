import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:misr_hydraulics/features/branch_users/add_branch_and_user_dialog.dart';
import 'package:misr_hydraulics/features/branch_users/add_user_to_branch_dialog.dart';
import 'package:misr_hydraulics/features/loading.dart';
import '../../providers.dart';

final branchesStreamProvider = StreamProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepoProvider).watchAll();
});
final usersStreamProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  return ref.watch(userRepoProvider).watchAll();
});

class BranchUsersTab extends ConsumerWidget {
  const BranchUsersTab({super.key});

  void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم النسخ')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesStreamProvider);
    final users = ref.watch(usersStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
              context: context, builder: (_) => const AddBranchAndUserDialog()),
          icon: const Icon(Icons.add_business),
          label: const Text('إضافة فرع + بائع'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: users.when(
            loading: () => const Loading(),
            error: (e, st) => Center(child: Text('خطأ: $e')),
            data: (usersList) {
              return branches.when(
                loading: () => const Loading(),
                error: (e, st) => Center(child: Text('خطأ الفروع: $e')),
                data: (branchList) {
                  if (branchList.isEmpty) {
                    return const Center(child: Text('لا توجد فروع بعد'));
                  }

                  return ListView.separated(
                    itemCount: branchList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final b = branchList[i];
                      final sellers = usersList
                          .where((u) => u.branchId == b.id)
                          .toList()
                        ..sort((a, b) => a.username.compareTo(b.username));

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.store_mall_directory_outlined),
                                  const SizedBox(width: 8),
                                  Text(b.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(width: 12),
                                  Text(
                                      'الهاتف: ${b.phone!.isEmpty ? '-' : b.phone}'),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'نسخ اسم الفرع',
                                    onPressed: () => copy(context, b.name),
                                    icon: const Icon(Icons.copy),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AddUserToBranchDialog(branch: b),
                                      );
                                    },
                                    icon: const Icon(Icons.person_add_alt),
                                    label: const Text('إضافة بائع'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                                    onPressed: () async {
                                      final ok = await showDeleteBranchDialog(
                                          context,
                                          sellersCount: sellers.length);
                                      if (ok == true) {
                                        for (final u in sellers) {
                                          await ref
                                              .read(userRepoProvider)
                                              .delete(u.id);
                                        }
                                        await ref
                                            .read(branchRepoProvider)
                                            .delete(b.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'تم حذف الفرع و البائعين')));
                                        }
                                      }
                                    },
                                    child: const Text('حذف الفرع'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (sellers.isEmpty)
                                const Text('لا يوجد بائعين لهذا الفرع'),
                              if (sellers.isNotEmpty)
                                Column(
                                  children: sellers
                                      .map((u) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: ListTile(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              tileColor: const Color.fromARGB(
                                                  64, 213, 195, 140),
                                              leading: Icon(
                                                  u.role == UserRole.admin
                                                      ? Icons.shield_rounded
                                                      : Icons.person_outline),
                                              title: Text(u.username),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'النوع: ${u.role.name == 'admin' ? 'مسؤول' : 'بائع'}'),
                                                  Text(
                                                      'كلمة المرور: ${u.password}')
                                                ],
                                              ),
                                              trailing: Wrap(
                                                spacing: 8,
                                                children: [
                                                  IconButton(
                                                    tooltip: 'نسخ اسم البائع',
                                                    onPressed: () => copy(
                                                        context, u.username),
                                                    icon:
                                                        const Icon(Icons.copy),
                                                  ),
                                                  FilledButton.tonal(
                                                    onPressed: () async {
                                                      final ok =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child: AlertDialog(
                                                            title: const Text(
                                                                'حذف البائع'),
                                                            content: const Text(
                                                                'هل تريد حذف هذا البائع؟'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        false),
                                                                child:
                                                                    const Text(
                                                                        'إلغاء'),
                                                              ),
                                                              FilledButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        true),
                                                                child:
                                                                    const Text(
                                                                        'حذف'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                      if (ok == true) {
                                                        await ref
                                                            .read(
                                                                userRepoProvider)
                                                            .delete(u.id);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'تم حذف البائع')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: const Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> showDeleteBranchDialog(BuildContext context,
      {required int sellersCount}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الفرع'),
          content: Text(sellersCount > 0
              ? 'سيتم أيضاً حذف $sellersCount مستخدم(ين) مرتبطين بهذا الفرع. هل تريد المتابعة؟'
              : 'هل تريد حذف هذا الفرع؟'),
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
  }
}
