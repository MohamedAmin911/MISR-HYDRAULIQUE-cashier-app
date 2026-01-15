import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

final productRepoProvider = Provider<ProductRepo>((ref) => ProductRepo());
final branchRepoProvider = Provider<BranchRepo>((ref) => BranchRepo());
final userRepoProvider = Provider<UserRepo>((ref) => UserRepo());
final txRepoProvider = Provider<TxRepo>((ref) => TxRepo());
final productRepositoryProvider =
    Provider<ProductRepo>((ref) => ref.read(productRepoProvider));
final categoryRepositoryProvider =
    Provider<CategoryRepo>((ref) => CategoryRepo());

final expenseRepoProvider = Provider<ExpenseRepo>((ref) => ExpenseRepo());
