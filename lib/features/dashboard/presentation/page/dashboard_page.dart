import 'package:fleet_maintenance_app/features/vehicles/presentation/pages/vehicle_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/menu_utils.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/home_tab.dart';
import '../widgets/placeholder_tabs.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

import '../../../users/presentation/pages/user_list_page.dart';
import '../../../users/presentation/pages/chauffeur_list_page.dart';
import '../../../faults/presentation/pages/fault_list_page.dart';
import '../../../work_orders/presentation/pages/work_order_list_page.dart';
import '../../../requests/presentation/pages/demandes_page.dart';

import '../../../inventory/presentation/pages/materiels_screen.dart';
import '../../../suppliers/presentation/pages/fournisseurs_screen.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _titles = [
    'Tableau de bord', 'Véhicules',    'Pannes',
    'Atelier',         'Demandes',    'Chauffeurs',
    'Matériels',       'Fournisseurs', 'Utilisateurs',
  ];

  static const _tabs = <Widget>[
    HomeTab(),         VehicleListPage(),     FaultListPage(),
    WorkOrderListPage(),      DemandesPage(),    ChauffeurListPage(),
    MaterielsScreen(),    FournisseursScreen(), UserListPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      final allowedItems = NavItem.getItemsByRole(user?.role);
      if (allowedItems.isNotEmpty && !allowedItems.any((it) => it.index == _selectedIndex)) {
        setState(() => _selectedIndex = allowedItems.first.index);
      }
    });
  }

  void _onSelect(int index) {
    if (index == -1) return;
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      key:             _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
        width: 250,
        backgroundColor: AppColors.sidebarBg,
        child: AppSidebar(
          selectedIndex: _selectedIndex,
          onSelect:      _onSelect,
          onClose:       () => Navigator.of(context).pop(),
        ),
      )
          : null,

      appBar: AppTopBar(
        pageTitle: _titles[_selectedIndex],
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),

      body: Row(children: [
        if (!isMobile)
          AppSidebar(selectedIndex: _selectedIndex, onSelect: _onSelect),
        Expanded(child: _tabs[_selectedIndex]),
      ]),
    );
  }
}
