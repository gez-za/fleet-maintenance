import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/dashboard/presentation/page/Dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings,
      WidgetRef ref,
      ) {
    final authState = ref.read(authNotifierProvider);

    switch (settings.name) {
      case '/login':
        if (authState.isAuthenticated) {
          return _page(const DashboardPage());
        }
        return _page(const LoginPage());

      case '/register':
        return _page(const RegisterPage());

      case '/dashboard':
        if (!authState.isAuthenticated) {
          return _page(const LoginPage());
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