import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../ui/app_scaffold.dart';
import '../ui/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'debts_screen.dart';
import 'expenses_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import 'pos_screen.dart';
import 'prices_screen.dart';
import 'report_screen.dart';
import 'search_screen.dart';
import 'barcode_scan_screen.dart';

enum CrmSection {
  dashboard,
  orders,
  inventory,
  prices,
  report,
  expenses,
  debts,
  pos,
  barcode,
}

class CrmShell extends StatefulWidget {
  const CrmShell({super.key});

  @override
  State<CrmShell> createState() => _CrmShellState();
}

class _CrmShellState extends State<CrmShell> {
  CrmSection _section = CrmSection.dashboard;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return;
        }
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        if (_section != CrmSection.dashboard) {
          setState(() => _section = CrmSection.dashboard);
          return;
        }
        SystemNavigator.pop();
      },
      child: AppScaffold(
        scaffoldKey: _scaffoldKey,
        title: _titleFor(_section),
        drawer: _CrmDrawer(
          current: _section,
          onSelect: (section) {
            setState(() => _section = section);
            Navigator.of(context).pop();
          },
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _bottomNavIndex(_section),
          items: const [
            AppBottomNavItem(icon: Icons.grid_view_rounded, label: 'Asosiy'),
            AppBottomNavItem(
                icon: Icons.receipt_long_outlined, label: 'Buyurtmalar'),
            AppBottomNavItem(
                icon: Icons.inventory_2_outlined, label: 'Mahsulotlar'),
            AppBottomNavItem(icon: Icons.bar_chart_outlined, label: 'Hisobot'),
            AppBottomNavItem(icon: Icons.qr_code_scanner, label: 'Skaner'),
          ],
          onTap: (index) {
            setState(() {
              _section = _sectionForBottomNav(index);
            });
          },
        ),
        body: _buildBody(),
      ),
    );
  }

  String _titleFor(CrmSection section) {
    switch (section) {
      case CrmSection.dashboard:
        return 'BilimCRM';
      case CrmSection.orders:
        return 'Buyurtmalar';
      case CrmSection.inventory:
        return 'Mahsulotlar';
      case CrmSection.prices:
        return 'Narxlar';
      case CrmSection.report:
        return 'Hisobot';
      case CrmSection.expenses:
        return 'Chiqimlar';
      case CrmSection.debts:
        return 'Qarzdorlar';
      case CrmSection.pos:
        return 'POS';
      case CrmSection.barcode:
        return 'Barcode skaner';
    }
  }

  int _bottomNavIndex(CrmSection section) {
    switch (section) {
      case CrmSection.dashboard:
        return 0;
      case CrmSection.orders:
        return 1;
      case CrmSection.inventory:
        return 2;
      case CrmSection.report:
        return 3;
      case CrmSection.barcode:
        return 4;
      default:
        return 0;
    }
  }

  CrmSection _sectionForBottomNav(int index) {
    switch (index) {
      case 1:
        return CrmSection.orders;
      case 2:
        return CrmSection.inventory;
      case 3:
        return CrmSection.report;
      case 4:
        return CrmSection.barcode;
      default:
        return CrmSection.dashboard;
    }
  }

  Widget _buildBody() {
    switch (_section) {
      case CrmSection.dashboard:
        return const DashboardScreen();
      case CrmSection.orders:
        return const OrdersScreen();
      case CrmSection.inventory:
        return const InventoryScreen();
      case CrmSection.prices:
        return const PricesScreen();
      case CrmSection.report:
        return const ReportScreen();
      case CrmSection.expenses:
        return const ExpensesScreen();
      case CrmSection.debts:
        return const DebtsScreen();
      case CrmSection.pos:
        return const PosScreen();
      case CrmSection.barcode:
        return const BarcodeScanScreen();
    }
  }
}

class _CrmDrawer extends StatelessWidget {
  const _CrmDrawer({required this.current, required this.onSelect});

  final CrmSection current;
  final ValueChanged<CrmSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppGradients.header),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.inventory_2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Bilim uz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Qidirish',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CrmSearchScreen(initialQuery: query),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _DrawerItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Boshqaruv',
                    selected: current == CrmSection.dashboard,
                    onTap: () => onSelect(CrmSection.dashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Buyurtmalar',
                    selected: current == CrmSection.orders,
                    onTap: () => onSelect(CrmSection.orders),
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Mahsulotlar',
                    selected: current == CrmSection.inventory,
                    onTap: () => onSelect(CrmSection.inventory),
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Hisobot',
                    selected: current == CrmSection.report,
                    onTap: () => onSelect(CrmSection.report),
                  ),
                  _DrawerItem(
                    icon: Icons.sell_outlined,
                    label: 'Narxlar',
                    selected: current == CrmSection.prices,
                    onTap: () => onSelect(CrmSection.prices),
                  ),
                  _DrawerItem(
                    icon: Icons.money_off_csred_outlined,
                    label: 'Chiqimlar',
                    selected: current == CrmSection.expenses,
                    onTap: () => onSelect(CrmSection.expenses),
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Qarzdorlar',
                    selected: current == CrmSection.debts,
                    onTap: () => onSelect(CrmSection.debts),
                  ),
                  _DrawerItem(
                    icon: Icons.point_of_sale,
                    label: 'POS',
                    selected: current == CrmSection.pos,
                    onTap: () => onSelect(CrmSection.pos),
                  ),
                  _DrawerItem(
                    icon: Icons.qr_code_scanner,
                    label: 'Barcode skaner',
                    selected: current == CrmSection.barcode,
                    onTap: () => onSelect(CrmSection.barcode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentPrimary : AppColors.textSecondary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      selected: selected,
      onTap: onTap,
    );
  }
}
