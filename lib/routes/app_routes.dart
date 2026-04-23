import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/profile_view_page.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/dashboard/presentation/page/Dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings,
      WidgetRef ref,
      ) {
final authState = ref.read(authProvider);
    final user = authState.user;

    switch (settings.name) {
      case '/profile':
        if (user == null) {
          return _page(const LoginPage());
        }
        return _page(const ProfileViewPage());

      case '/login':
        if (user != null) {
          if (!user.isProfileComplete) {
            return _page(const ProfilePage());
          }
          return _page(const DashboardPage());
        }
        return _page(const LoginPage());

      case '/register':
        return _page(const RegisterPage());

      case '/profile-setup':
        if (user == null) {
          return _page(const LoginPage());
        }
        return _page(const ProfilePage());

      case '/dashboard':
        if (user == null) {
          return _page(const LoginPage());
        }
        if (!user.isProfileComplete) {
          return _page(const ProfilePage());
        }
        return _page(const DashboardPage());

      default:
        return _page(const LoginPage());
    }
  }

  static MaterialPageRoute _page(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
