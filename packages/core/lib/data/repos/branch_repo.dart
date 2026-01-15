import 'dart:async';
import '../local_db.dart';
import '../models/branch.dart';

class BranchRepo {
  Stream<List<Branch>> watchAll() async* {
    final box = LocalDb.branches;
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  Future<int> add(String name, String phone) async {
    final b = Branch()
      ..name = name
      ..phone = phone
      ..createdAt = DateTime.now();
    final key = await LocalDb.branches.add(b);
    b.id = key;
    await LocalDb.branches.put(key, b);
    return key;
  }

  Future<void> delete(int id) async {
    await LocalDb.branches.delete(id);
  }
}
