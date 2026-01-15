import 'dart:async';

import '../local_db.dart';
import '../models/sale_transaction.dart';
import '../models/transaction_item.dart';

class TxRepo {
  // Watch all transactions, newest first
  Stream<List<SaleTx>> watchAllDesc() async* {
    final box = LocalDb.transactions;

    List<SaleTx> sortDesc() {
      final l = box.values.toList();
      l.sort((a, b) => b.date.compareTo(a.date));
      return l;
    }

    yield sortDesc();
    yield* box.watch().map((_) => sortDesc());
  }

  // Watch by seller, newest first
  Stream<List<SaleTx>> watchBySellerDesc(int sellerUserId) async* {
    final box = LocalDb.transactions;

    List<SaleTx> sortDesc() {
      final l =
          box.values.where((t) => t.sellerUserId == sellerUserId).toList();
      l.sort((a, b) => b.date.compareTo(a.date));
      return l;
    }

    yield sortDesc();
    yield* box.watch().map((_) => sortDesc());
  }

  Future<SaleTx> create({
    required double craftPrice,
    required int sellerUserId,
    required String sellerUsername,
    required int? branchId,
    required String branchName,
    required String customerName,
    required List<Map<String, dynamic>> cartItems, // [{productId, qty}]
  }) async {
    // Decrement stock + create transaction
    double totalSell = 0;
    double totalCost = 0;
    final items = <TxItem>[];

    for (final it in cartItems) {
      final pid = it['productId'] as int;
      final qty = it['qty'] as int;

      final p = LocalDb.products.get(pid);
      if (p == null) {
        throw Exception('المنتج غير موجود');
      }
      if (p.quantity < qty) {
        throw Exception('الكمية غير كافية للمنتج: ${p.name}');
      }

      // Update stock
      p.quantity -= qty;
      await LocalDb.products.put(pid, p);

      // Snapshot prices at sale time
      final base = p.sellPrice; // سعر البيع الأساسي (بدون مصنعية)
      final craft = p.craftPrice; // المصنعية لكل وحدة
      final unitTotal = base + craft; // المجموع للوحدة
      final buy = p.buyPrice; // التكلفة الداخلية

      items.add(
        TxItem()
          ..productId = pid
          ..productName = p.name
          ..categoryName = p.categoryName
          ..buyPriceAtSale = buy
          ..baseSellPriceAtSale = base
          ..craftPriceAtSale = craft
          ..sellPriceAtSale = unitTotal // kept for totals/back-compat
          ..quantity = qty,
      );

      totalSell += unitTotal * qty; // الإيراد الصحيح
      totalCost += buy * qty; // تكلفة الشراء الداخلية
    }

    // Snapshot branch phone (for receipt header)
    String phoneSnapshot = '';
    if (branchId != null) {
      final b = LocalDb.branches.get(branchId);
      phoneSnapshot = b?.phone ?? '';
    }

    final tx = SaleTx()
      ..date = DateTime.now()
      ..sellerUserId = sellerUserId
      ..sellerUsername = sellerUsername
      ..branchId = branchId
      ..branchName = branchName
      ..branchPhone = phoneSnapshot
      ..customerName = customerName
      ..items = items
      ..craftPrice = craftPrice
      ..totalSell = totalSell
      ..totalCost = totalCost
      ..totalProfit = totalSell - totalCost;

    final key = await LocalDb.transactions.add(tx);
    tx.id = key;
    await LocalDb.transactions.put(key, tx);
    return tx;
  }

  Future<void> delete(int id, {bool restock = false}) async {
    final tx = LocalDb.transactions.get(id);
    if (tx == null) return;

    if (restock) {
      for (final it in tx.items) {
        final p = LocalDb.products.get(it.productId);
        if (p != null) {
          p.quantity += it.quantity;
          await LocalDb.products.put(p.id, p);
        }
      }
    }

    await LocalDb.transactions.delete(id);
  }
}
