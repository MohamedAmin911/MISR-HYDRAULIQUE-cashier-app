import 'package:hive/hive.dart';
import 'transaction_item.dart';

part 'sale_transaction.g.dart';

@HiveType(typeId: 5)
class SaleTx {
  @HiveField(0)
  int id = -1;

  @HiveField(1)
  DateTime date = DateTime.now();

  @HiveField(2)
  int? sellerUserId;

  @HiveField(3)
  String sellerUsername = '';

  @HiveField(4)
  int? branchId;

  @HiveField(5)
  String branchName = '';

  @HiveField(6)
  String customerName = '';

  @HiveField(7)
  List<TxItem> items = [];

  @HiveField(8)
  double totalSell = 0;

  @HiveField(9)
  double totalCost = 0;

  @HiveField(10)
  double totalProfit = 0;

  @HiveField(11)
  String? branchPhone;

  @HiveField(12)
  double craftPrice = 0;
}
