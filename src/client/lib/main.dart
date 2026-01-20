import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/admin/presentation/admin_dashboard.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/buyer/presentation/buyer_dashboard.dart';
import 'features/developer/presentation/developer_dashboard.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const AuthScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/buyer': (_) => const BuyerDashboard(),
        '/developer': (_) => const DeveloperDashboard(),
      },
    );
  }
}