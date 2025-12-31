import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_routes.dart';
import '../core/services/database_service.dart';

/// Écran de démarrage de l'application
///
/// Affiche le logo et charge les ressources nécessaires
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialiser l'application
  Future<void> _initializeApp() async {
    try {
      // Attendre un minimum de 2 secondes pour l'effet visuel
      await Future.wait([
        _loadResources(),
        Future.delayed(const Duration(seconds: 2)),
      ]);

      // Navigation vers l'écran de connexion
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      // Afficher une erreur
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  /// Charger les ressources nécessaires
  Future<void> _loadResources() async {
    // Initialiser la base de données
    await DatabaseService.instance.database;

    // TODO: Charger d'autres ressources si nécessaire
    // - Configuration
    // - Préférences utilisateur
    // - Cache
  }

  /// Afficher une erreur
  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Erreur de démarrage'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  // Réessayer
                  Navigator.of(context).pop();
                  _initializeApp();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                  boxShadow: AppStyles.shadowLarge,
                ),
                child: Icon(
                  Icons.point_of_sale,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppStyles.paddingXL),

              // Nom de l'application
              Text(
                AppConstants.appName,
                style: AppStyles.heading1.copyWith(
                  color: AppColors.textLight,
                  fontSize: 36,
                ),
              ),

              const SizedBox(height: AppStyles.paddingS),

              // Slogan
              Text(
                'Gestion professionnelle de point de vente',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textLight.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppStyles.paddingXL * 2),

              // Indicateur de chargement
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textLight,
                  ),
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(height: AppStyles.paddingL),

              // Texte de chargement
              Text(
                'Chargement...',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textLight.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: AppStyles.paddingXL * 3),

              // Version
              Text(
                'Version ${AppConstants.appVersion}',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textLight.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
