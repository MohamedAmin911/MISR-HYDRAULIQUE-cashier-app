import 'package:hive/hive.dart';

part 'role.g.dart';

@HiveType(typeId: 10)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  seller,
}
