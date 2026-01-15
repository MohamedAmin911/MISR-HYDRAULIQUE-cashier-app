import 'dart:async';
import '../local_db.dart';
import '../models/expense.dart';

class ExpenseRepo {
  Stream<List<Expense>> watchAll() async* {
    final box = LocalDb.expenses;
    yield box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    yield* box.watch().map((_) {
      final l = box.values.toList();
      l.sort((a, b) => b.date.compareTo(a.date));
      return l;
    });
  }

  Future<int> add(
      {required String title, required double amount, DateTime? date}) async {
    final e = Expense()
      ..title = title
      ..amount = amount
      ..date = date ?? DateTime.now();
    final key = await LocalDb.expenses.add(e);
    e.id = key;
    await LocalDb.expenses.put(key, e);
    return key;
  }

  Future<void> delete(int id) async => LocalDb.expenses.delete(id);
}
