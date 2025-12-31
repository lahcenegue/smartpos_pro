import 'package:flutter/material.dart';
import 'package:smartpos_pro/core/utils/demo_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'core/services/database_service.dart';
import 'core/constants/app_styles.dart';
import 'core/constants/app_routes.dart';
import 'providers/vente_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SQLite pour Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialiser la base de données (elle sera créée automatiquement)
  await DatabaseService.instance.database;

  // Insérer des produits de démo (seulement au premier lancement)
  await DemoData.insererProduitsDeMo();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider pour les ventes
        ChangeNotifierProvider(create: (_) => VenteProvider()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
