import 'package:hive/hive.dart';

part 'transaction_item.g.dart';

@HiveType(typeId: 4)
class TxItem {
  @HiveField(0)
  late int productId;

  @HiveField(1)
  String productName = '';

  @HiveField(2)
  double craftPriceAtSale = 0;

  @HiveField(3)
  double sellPriceAtSale = 0;

  @HiveField(4)
  int quantity = 0;

  @HiveField(5)
  String? categoryName;

  @HiveField(6)
  double? baseSellPriceAtSale;

  @HiveField(7)
  double? buyPriceAtSale;

  @HiveField(8)
  double? buyPrice;
}
