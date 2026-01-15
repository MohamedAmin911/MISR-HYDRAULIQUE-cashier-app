import 'dart:async';
import '../local_db.dart';
import '../models/user.dart';
import '../models/role.dart';

class UserRepo {
  Stream<List<AppUser>> watchAll() async* {
    final box = LocalDb.users;
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  Future<int> add({
    required String username,
    required String password,
    required UserRole role,
    required String? phone,
    int? branchId,
    String branchName = '',
  }) async {
    final u = AppUser()
      ..username = username
      ..password = password
      ..role = role
      ..branchId = branchId
      ..branchName = branchName
      ..createdAt = DateTime.now();
    final key = await LocalDb.users.add(u);
    u.id = key;
    await LocalDb.users.put(key, u);
    return key;
  }

  Future<AppUser?> login(String username, String password) async {
    final all = LocalDb.users.values;
    try {
      return all.firstWhere(
        (u) =>
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(int id) async {
    await LocalDb.users.delete(id);
  }
}
