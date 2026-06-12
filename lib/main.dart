import 'package:fleet_maintenance_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/dashboard/presentation/page/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp( const ProviderScope(
    child: MyApp(),
  ),);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Fleet management',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      
      home: authState.isLoading
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_car_filled, size: 64, color: Color(0xFF1565C0)),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          : (authState.isAuthenticated 
              ? (authState.user!.isProfileComplete ? const DashboardPage() : const ProfilePage())
              : const LoginPage()),

      onGenerateRoute: (settings) => AppRouter.generateRoute(settings, ref),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
      ),
    );
  }
}
