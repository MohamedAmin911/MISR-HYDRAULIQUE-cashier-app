import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../providers.dart';
import 'add_branch_dialog.dart';

final branchesStreamProvider = StreamProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepoProvider).watchAll();
});

class BranchesTab extends ConsumerWidget {
  const BranchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesStreamProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
              context: context, builder: (_) => const AddBranchDialog()),
          icon: const Icon(Icons.add_business),
          label: const Text('إضافة فرع'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: branches.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('خطأ: $e')),
            data: (list) {
              if (list.isEmpty)
                return const Center(child: Text('لا توجد فروع بعد'));
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(b.name),
                      subtitle:
                          Text('الهاتف: ${b.phone!.isEmpty ? '-' : b.phone}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
