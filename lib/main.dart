import 'package:fleet_maintenance_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

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

    if (authState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
        ),
      );
    }

    return MaterialApp(
      title: 'Fleet management',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),

      initialRoute: '/',

      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          if (authState.isAuthenticated) {
            return AppRouter.generateRoute(const RouteSettings(name: '/dashboard'), ref);
          } else {
            return AppRouter.generateRoute(const RouteSettings(name: '/login'), ref);
          }
        }
        return AppRouter.generateRoute(settings, ref);
      },
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
