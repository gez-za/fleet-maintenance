import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_topBar.dart';
import '../widgets/home_tab.dart';
import '../widgets/placeholder_tabs.dart';

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
    'Atelier',         'Carburant',    'Chauffeurs',
    'Matériels',       'Fournisseurs',
  ];

  static const _tabs = <Widget>[
    HomeTab(),         VehiclesTab(),     PannesTab(),
    AtelierTab(),      CarburantTab(),    ChauffeursTab(),
    MaterielsTab(),    FournisseursTab(),
  ];

  void _onSelect(int index) {
    if (index == -1) return; // Paramètres non gérés ici pour le moment
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
