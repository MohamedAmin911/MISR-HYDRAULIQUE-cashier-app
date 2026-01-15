import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartItemModel {
  final int productId;
  final String productName;
  final double sellPrice;
  final double craftPrice;
  final int quantity;
  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.sellPrice,
    required this.quantity,
    required this.craftPrice,
  });

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        productId: productId,
        productName: productName,
        sellPrice: sellPrice,
        craftPrice: craftPrice,
        quantity: quantity ?? this.quantity,
      );
}

class CartController extends StateNotifier<List<CartItemModel>> {
  CartController() : super(const []);

  void addOrUpdate({
    required int productId,
    required String name,
    required double sellPrice,
    required double craftPrice,
    required int addQuantity,
    required int maxAvailable,
  }) {
    final list = [...state];
    final idx = list.indexWhere((e) => e.productId == productId);
    if (idx >= 0) {
      final it = list[idx];
      final newQty = (it.quantity + addQuantity).clamp(1, maxAvailable);
      list[idx] = it.copyWith(quantity: newQty);
    } else {
      list.add(CartItemModel(
        productId: productId,
        productName: name,
        sellPrice: sellPrice,
        craftPrice: craftPrice,
        quantity: addQuantity.clamp(1, maxAvailable),
      ));
    }
    state = list;
  }

  void increment(int productId, {required int maxAvailable}) {
    final list = [...state];
    final idx = list.indexWhere((e) => e.productId == productId);
    if (idx >= 0) {
      final it = list[idx];
      final newQty = (it.quantity + 1).clamp(1, maxAvailable);
      list[idx] = it.copyWith(quantity: newQty);
      state = list;
    }
  }

  void decrement(int productId) {
    final list = [...state];
    final idx = list.indexWhere((e) => e.productId == productId);
    if (idx >= 0) {
      final it = list[idx];
      final q = it.quantity - 1;
      if (q <= 0) {
        list.removeAt(idx);
      } else {
        list[idx] = it.copyWith(quantity: q);
      }
      state = list;
    }
  }

  void remove(int productId) {
    state = state.where((e) => e.productId != productId).toList();
  }

  void clear() => state = const [];
}

final cartProvider =
    StateNotifierProvider<CartController, List<CartItemModel>>((ref) {
  return CartController();
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, e) => sum + e.sellPrice * e.quantity);
});

final customerNameProvider = StateProvider<String>((ref) => '');
