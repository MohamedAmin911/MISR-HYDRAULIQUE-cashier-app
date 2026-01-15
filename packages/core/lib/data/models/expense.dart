import 'package:hive/hive.dart';
part 'expense.g.dart';

@HiveType(typeId: 8)
class Expense {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  String title = '';

  @HiveField(2)
  double amount = 0;

  @HiveField(3)
  DateTime date = DateTime.now();
}
