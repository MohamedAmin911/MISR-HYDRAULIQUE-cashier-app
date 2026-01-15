import 'package:hive/hive.dart';
import 'role.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class AppUser {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  late String username;

  @HiveField(2)
  String password = '';

  @HiveField(3)
  UserRole role = UserRole.seller;

  @HiveField(4)
  int? branchId;

  @HiveField(5)
  String branchName = '';

  @HiveField(6)
  DateTime createdAt = DateTime.now();
}
