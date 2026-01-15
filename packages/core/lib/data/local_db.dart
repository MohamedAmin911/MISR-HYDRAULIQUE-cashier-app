import 'package:core/data/models/category.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/branch.dart';
import 'models/user.dart';
import 'models/product.dart';
import 'models/sale_transaction.dart';
import 'models/transaction_item.dart';
import 'models/role.dart';

import 'models/expense.dart';

class LocalDb {
  static bool _inited = false;

  static Future<void> open() async {
    if (_inited) return;
    await Hive.initFlutter();

// Register adapters once
    Hive
      ..registerAdapter(UserRoleAdapter())
      ..registerAdapter(BranchAdapter())
      ..registerAdapter(AppUserAdapter())
      ..registerAdapter(ProductAdapter())
      ..registerAdapter(TxItemAdapter())
      ..registerAdapter(SaleTxAdapter())
      ..registerAdapter(CategoryAdapter())
      ..registerAdapter(ExpenseAdapter());

// Open boxes
    await Future.wait([
      Hive.openBox<Branch>('branches'),
      Hive.openBox<AppUser>('users'),
      Hive.openBox<Product>('products'),
      Hive.openBox<SaleTx>('transactions'),
      Hive.openBox<Category>('categories'),
      Hive.openBox<Expense>('expenses'),
    ]);

    _inited = true;
  }

  static Box<Branch> get branches => Hive.box<Branch>('branches');
  static Box<AppUser> get users => Hive.box<AppUser>('users');
  static Box<Product> get products => Hive.box<Product>('products');
  static Box<SaleTx> get transactions => Hive.box<SaleTx>('transactions');
  static Box<Category> get categories => Hive.box<Category>('categories');
  static Box<Expense> get expenses => Hive.box<Expense>('expenses');
}

// Seed admin (first run)
Future<void> seedAdminIfMissing() async {
  final u = LocalDb.users;
  if (u.isNotEmpty) return;

  final b = Branch()
    ..name = 'الفرع الرئيسي'
    ..phone = ''
    ..createdAt = DateTime.now();
  final branchKey = await LocalDb.branches.add(b);
  b.id = branchKey;
  await LocalDb.branches.put(branchKey, b);

  final admin = AppUser()
    ..username = 'admin'
    ..password = 'Admin#2025'
    ..role = UserRole.admin
    ..branchId = branchKey
    ..branchName = b.name
    ..createdAt = DateTime.now();
  final userKey = await LocalDb.users.add(admin);
  admin.id = userKey;
  await LocalDb.users.put(userKey, admin);
}
