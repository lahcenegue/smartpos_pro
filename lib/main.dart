import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/database_service.dart';
import 'core/constants/app_styles.dart';
import 'core/constants/app_routes.dart';
import 'core/utils/demo_data.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SQLite pour Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialiser les locales pour le formatage des dates
  await initializeDateFormatting('fr_FR', null);

  // Initialiser la base de données
  await DatabaseService.instance.database;

  // Insérer des produits de démo
  await DemoData.insererProduitsDeMo();

  runApp(
    const ProviderScope(
      // ← AJOUTER ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPOS Pro',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.lightTheme,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),

      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
    );
  }
}
