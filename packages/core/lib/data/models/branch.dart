import 'package:hive/hive.dart';

part 'branch.g.dart';

@HiveType(typeId: 1)
class Branch {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  DateTime createdAt = DateTime.now();
}
