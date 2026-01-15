import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misr_hydraulics/features/analytics/analytics_tab.dart';

import '../../session/session_provider.dart';
import '../branch_users/branch_users_tab.dart';
import '../products/products_tab.dart';
import '../products/seller_products_tab.dart';
import '../cart/cart_tab.dart';
import '../transactions/transactions_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(sessionProvider)?.role.name == 'admin';

    final pages = isAdmin
        ? <Widget>[
            const ProductsTab(),
            const BranchUsersTab(),
            // const CartTab(),
            const TransactionsTab(),
            const AnalyticsTab(),
          ]
        : <Widget>[
            const SellerProductsTab(),
            const CartTab(),
            const TransactionsTab(),
          ];

    final destinations = isAdmin
        ? <NavigationDestination>[
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'المنتجات',
            ),
            const NavigationDestination(
              icon: Icon(Icons.groups_2_outlined),
              label: 'الفروع و البائعين',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'العمليات',
            ),
            const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              label: 'التحليلات',
            ),
          ]
        : <NavigationDestination>[
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'المنتجات',
            ),
            const NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'السلة',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'العمليات',
            ),
          ];

// Keep index in range if role changes (number of tabs changes)
    index = index.clamp(0, pages.length - 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170), // adjust height as needed
          child: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            flexibleSpace: SafeArea(
              bottom: false,
              child: SizedBox.expand(
                child: Image.asset(
                  'images/strip.jpg',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: pages[index],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: destinations,
        ),
      ),
    );
  }
}
