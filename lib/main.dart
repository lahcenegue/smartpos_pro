import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/services/database_service.dart';
import 'core/constants/app_styles.dart';
import 'core/constants/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SQLite pour Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialiser la base de données
  await DatabaseService.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPOS Pro',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.lightTheme,

      // Route initiale
      initialRoute: AppRoutes.splash,

      // Configuration des routes
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
    );
  }
}
