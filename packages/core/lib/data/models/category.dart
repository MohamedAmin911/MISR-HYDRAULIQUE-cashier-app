import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 6)
class Category {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  String name = '';
}
