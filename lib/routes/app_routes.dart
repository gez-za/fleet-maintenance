import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/profile_view_page.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/dashboard/presentation/page/Dashboard_page.dart';

// ✅ VEHICULES
import '../features/vehicles/models/vehicle.dart';
import '../features/vehicles/presentation/pages/vehicle_list_page.dart';
import '../features/vehicles/presentation/pages/add_vehicle_page.dart';
import '../features/vehicles/presentation/pages/vehicle_detail_page.dart';
import '../features/vehicles/presentation/pages/edit_vehicle_page.dart';

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
        if (user == null) return _page(const LoginPage());
        return _page(const ProfileViewPage());

      case '/login':
        if (user != null) {
          if (!user.isProfileComplete) return _page(const ProfilePage());
          return _page(const DashboardPage());
        }
        return _page(const LoginPage());

      case '/register':
        return _page(const RegisterPage());

      case '/profile-setup':
        if (user == null) return _page(const LoginPage());
        return _page(const ProfilePage());

      case '/dashboard':
        if (user == null) return _page(const LoginPage());
        if (!user.isProfileComplete) return _page(const ProfilePage());
        return _page(const DashboardPage());

    // ═══════════════════════════ VÉHICULES ══════════════════════════════

      case '/vehicles':
        if (user == null) return _page(const LoginPage());
        return _page(const VehicleListPage());

      case '/vehicles/add':
        if (user == null) return _page(const LoginPage());
        return _page(const AddVehiclePage());

    // arguments : String vehicleId
      case '/vehicles/detail':
        if (user == null) return _page(const LoginPage());
        final vehicleId = settings.arguments as String?;
        if (vehicleId == null) return _page(const VehicleListPage());
        return _page(VehicleDetailPage(vehicleId: vehicleId));

    // arguments : Vehicle vehicle
      case '/vehicles/edit':
        if (user == null) return _page(const LoginPage());
        final vehicle = settings.arguments as Vehicle?;
        if (vehicle == null) return _page(const VehicleListPage());
        return _page(EditVehiclePage(vehicle: vehicle));

    // ═══════════════════════════ DEFAULT ════════════════════════════════

      default:
        return _page(const LoginPage());
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget page) {
    return MaterialPageRoute<T>(builder: (_) => page);
  }
}