import 'dart:async';
import '../local_db.dart';
import '../models/category.dart';

class CategoryRepo {
  Stream<List<Category>> watchAll() async* {
    final box = LocalDb.categories;
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  Future<void> delete(int id) async {
    await LocalDb.categories.delete(id);
  }

  Future<int> add(String name) async {
    final c = Category()..name = name;
    final key = await LocalDb.categories.add(c);
    c.id = key;
    await LocalDb.categories.put(key, c);
    return key;
  }
}
