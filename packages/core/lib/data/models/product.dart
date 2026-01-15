import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 3)
class Product {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String categoryName = '';

  @HiveField(3)
  String description = '';

  @HiveField(4)
  double craftPrice = 0;

  @HiveField(5)
  double sellPrice = 0;

  @HiveField(6)
  int quantity = 0;

  @HiveField(7)
  DateTime createdAt = DateTime.now();

  @HiveField(8)
  DateTime updatedAt = DateTime.now();

  @HiveField(9)
  double buyPrice = 0;
}
