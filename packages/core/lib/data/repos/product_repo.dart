import 'dart:async';
import '../local_db.dart';
import '../models/product.dart';

class ProductRepo {
  Stream<List<Product>> watchAll() async* {
    final box = LocalDb.products;
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  Future<int> add(Product p) async {
    p.createdAt = DateTime.now();
    p.updatedAt = DateTime.now();
    final key = await LocalDb.products.add(p);
    p.id = key;
    await LocalDb.products.put(key, p);
    return key;
  }

  Future<void> update(Product p) async {
    p.updatedAt = DateTime.now();
    await LocalDb.products.put(p.id, p);
  }

  Future<void> delete(int id) async {
    await LocalDb.products.delete(id);
  }

  Future<void> incrementQuantity(int id, int delta) async {
    final box = LocalDb.products;
    final p = box.get(id);
    if (p == null) return;
    final next = p.quantity + delta;
    if (next < 0) throw Exception('الكمية لا يمكن أن تكون سالبة');
    p.quantity = next;
    p.updatedAt = DateTime.now();
    await box.put(id, p);
  }

  Product? getByIdSync(int id) => LocalDb.products.get(id);
}
