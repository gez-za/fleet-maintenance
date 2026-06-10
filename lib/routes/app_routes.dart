import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/profile_view_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/dashboard/presentation/page/dashboard_page.dart';

// ✅ VEHICULES
import '../features/vehicles/models/vehicle.dart';
import '../features/vehicles/presentation/pages/vehicle_list_page.dart';
import '../features/vehicles/presentation/pages/add_vehicle_page.dart';
import '../features/vehicles/presentation/pages/vehicle_detail_page.dart';
import '../features/vehicles/presentation/pages/edit_vehicle_page.dart';

// ✅ PANNES
import '../features/faults/models/fault.dart';
import '../features/faults/presentation/pages/fault_list_page.dart';
import '../features/faults/presentation/pages/declare_fault_page.dart';
import '../features/faults/presentation/pages/fault_detail_page.dart';

// ✅ ORDRES DE TRAVAIL
import '../features/work_orders/presentation/pages/work_order_list_page.dart';
import '../features/work_orders/presentation/pages/create_work_order_page.dart';
import '../features/work_orders/presentation/pages/work_order_detail_page.dart';

// ✅ DEMANDES & DÉPENSES
import '../features/requests/models/demande.dart';
import '../features/requests/presentation/pages/demandes_page.dart';
import '../features/requests/presentation/pages/create_demande_page.dart';
import '../features/requests/presentation/pages/demande_detail_page.dart';
import '../features/requests/presentation/pages/depenses_page.dart';

// ✅ INVENTAIRE & STOCK
import '../features/inventory/models/material.dart';
import '../features/inventory/presentation/pages/materiels_screen.dart';
import '../features/inventory/presentation/pages/materiel_details_screen.dart';
import '../features/inventory/presentation/pages/create_materiel_screen.dart';
import '../features/inventory/presentation/pages/stock_movement_screen.dart';
import '../features/inventory/presentation/pages/mouvements_history_screen.dart';
import '../features/inventory/presentation/pages/stock_alerts_screen.dart';

// ✅ FOURNISSEURS
import '../features/suppliers/models/supplier.dart';
import '../features/suppliers/presentation/pages/fournisseurs_screen.dart';
import '../features/suppliers/presentation/pages/fournisseur_details_screen.dart';
import '../features/suppliers/presentation/pages/fournisseur_catalogue_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings,
      WidgetRef ref,
      ) {
    final authState = ref.read(authProvider);
    final user      = authState.user;

    switch (settings.name) {
    // ═══════════════════════════ AUTH ═══════════════════════════════════

      case '/profile':
        if (user == null) {
          return _page(const LoginPage(), settings);
        }
        return _page(const ProfileViewPage(), settings);

      case '/login':
        if (user != null) {
          if (!user.isProfileComplete) return _page(const ProfilePage(), settings);
          return _page(const DashboardPage(), settings);
        }
        return _page(const LoginPage(), settings);

      case '/register':
        return _page(const RegisterPage(), settings);

      case '/forgot-password':
        return _page(const ForgotPasswordPage(), settings);

      case '/reset-password':
        return _page(const ResetPasswordPage(), settings);

      case '/profile-setup':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const ProfilePage(), settings);

      case '/dashboard':
        if (user == null) return _page(const LoginPage(), settings);
        if (!user.isProfileComplete) return _page(const ProfilePage(), settings);
        return _page(const DashboardPage(), settings);

    // ═══════════════════════════ VÉHICULES ══════════════════════════════

      case '/vehicles':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const VehicleListPage(), settings);

      case '/vehicles/add':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const AddVehiclePage(), settings);

    // arguments : String vehicleId
      case '/vehicles/detail':
        if (user == null) return _page(const LoginPage(), settings);
        final vehicleId = settings.arguments as String?;
        if (vehicleId == null) return _page(const VehicleListPage(), settings);
        return _page(VehicleDetailPage(vehicleId: vehicleId), settings);

    // arguments : Vehicle vehicle
      case '/vehicles/edit':
        if (user == null) return _page(const LoginPage(), settings);
        final vehicle = settings.arguments as Vehicle?;
        if (vehicle == null) return _page(const VehicleListPage(), settings);
        return _page(EditVehiclePage(vehicle: vehicle), settings);

    // ═══════════════════════════ PANNES ═════════════════════════════════

      case '/faults':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const FaultListPage(), settings);

      case '/faults/declare':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const DeclareFaultPage(), settings);

      case '/faults/detail':
        if (user == null) return _page(const LoginPage(), settings);
        final faultId = settings.arguments as String?;
        if (faultId == null) return _page(const FaultListPage(), settings);
        return _page(FaultDetailPage(faultId: faultId), settings);

    // ═══════════════════════════ ORDRES DE TRAVAIL ══════════════════════

      case '/work-orders':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const WorkOrderListPage(), settings);

      case '/work-orders/create':
        if (user == null) return _page(const LoginPage(), settings);
        final fault = settings.arguments as Fault?;
        if (fault == null) return _page(const FaultListPage(), settings);
        return _page(CreateWorkOrderPage(fault: fault), settings);

      case '/work-orders/detail':
        if (user == null) return _page(const LoginPage(), settings);
        final woId = settings.arguments as String?;
        if (woId == null) return _page(const WorkOrderListPage(), settings);
        return _page(WorkOrderDetailPage(woId: woId), settings);

    // ═══════════════════════════ DEMANDES ═══════════════════════════════

      case '/demandes':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const DemandesPage(), settings);

      case '/demandes/create':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const CreateDemandePage(), settings);

      case '/demandes/details':
        if (user == null) return _page(const LoginPage(), settings);
        final demande = settings.arguments as Demande?;
        if (demande == null) return _page(const DemandesPage(), settings);
        return _page(DemandeDetailPage(demande: demande), settings);

      case '/depenses':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const DepensesPage(), settings);

    // ═══════════════════════════ STOCK & MATÉRIELS ═══════════════════════

      case '/inventory':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const MaterielsScreen(), settings);

      case '/inventory/details':
        if (user == null) return _page(const LoginPage(), settings);
        final material = settings.arguments as MaterialModel?;
        if (material == null) return _page(const MaterielsScreen(), settings);
        return _page(MaterielDetailsScreen(material: material), settings);

      case '/inventory/create':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const CreateMaterielScreen(), settings);

      case '/inventory/move':
        if (user == null) return _page(const LoginPage(), settings);
        final material = settings.arguments as MaterialModel?;
        if (material == null) return _page(const MaterielsScreen(), settings);
        return _page(StockMovementScreen(material: material), settings);

      case '/inventory/history':
        if (user == null) return _page(const LoginPage(), settings);
        final materielId = settings.arguments as String?;
        return _page(MouvementsHistoryScreen(materielId: materielId), settings);

      case '/inventory/alerts':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const StockAlertsScreen(), settings);

    // ═══════════════════════════ FOURNISSEURS ════════════════════════════

      case '/suppliers':
        if (user == null) return _page(const LoginPage(), settings);
        return _page(const FournisseursScreen(), settings);

      case '/suppliers/details':
        if (user == null) return _page(const LoginPage(), settings);
        final supplier = settings.arguments as Supplier?;
        if (supplier == null) return _page(const FournisseursScreen(), settings);
        return _page(FournisseurDetailsScreen(supplier: supplier), settings);

      case '/suppliers/catalogue':
        if (user == null) return _page(const LoginPage(), settings);
        final supplier = settings.arguments as Supplier?;
        if (supplier == null) return _page(const FournisseursScreen(), settings);
        return _page(FournisseurCatalogueScreen(supplier: supplier), settings);

    // ═══════════════════════════ DEFAULT ════════════════════════════════

      default:
        return _page(const LoginPage(), settings);
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget page, RouteSettings settings) {
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }
}