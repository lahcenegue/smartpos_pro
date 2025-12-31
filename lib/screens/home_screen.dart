import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_routes.dart';
import '../core/services/auth_service.dart';
import '../widgets/layout/app_drawer.dart';

/// Écran principal de l'application
///
/// Contient le menu de navigation et affiche les différents modules
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService.instance;

  String _currentModule = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AppDrawer(
        currentModule: _currentModule,
        onModuleSelected: (module) {
          setState(() {
            _currentModule = module;
          });
          Navigator.of(context).pop(); // Fermer le drawer
        },
      ),
      body: _buildBody(),
    );
  }

  /// Construire l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getModuleTitle()),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      actions: [
        // Informations utilisateur
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingM),
          child: Center(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _authService.currentUser?.initiales ?? '?',
                    style: AppStyles.labelMedium.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingS),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authService.currentUser?.nomComplet ?? 'Utilisateur',
                      style: AppStyles.labelMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getRoleLabel(_authService.currentUser?.role ?? ''),
                      style: AppStyles.labelSmall.copyWith(
                        color: AppColors.textLight.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppStyles.paddingM),

        // Bouton de déconnexion
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Déconnexion',
          onPressed: _logout,
        ),

        const SizedBox(width: AppStyles.paddingS),
      ],
    );
  }

  /// Construire le corps de l'écran
  Widget _buildBody() {
    switch (_currentModule) {
      case 'dashboard':
        return _buildDashboard();
      case 'vente':
        return _buildPlaceholder('Module Vente', Icons.point_of_sale);
      case 'produits':
        return _buildPlaceholder('Module Produits', Icons.inventory);
      case 'stock':
        return _buildPlaceholder('Module Stock', Icons.warehouse);
      case 'clients':
        return _buildPlaceholder('Module Clients', Icons.people);
      case 'rapports':
        return _buildPlaceholder('Module Rapports', Icons.analytics);
      case 'fournisseurs':
        return _buildPlaceholder('Module Fournisseurs', Icons.local_shipping);
      case 'parametres':
        return _buildPlaceholder('Module Paramètres', Icons.settings);
      default:
        return _buildDashboard();
    }
  }

  /// Construire le dashboard d'accueil
  Widget _buildDashboard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                ),
                child: Icon(
                  Icons.dashboard,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppStyles.paddingXL),

              // Titre de bienvenue
              Text(
                'Bienvenue dans ${AppConstants.appName}',
                style: AppStyles.heading1.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppStyles.paddingM),

              Text(
                'Bonjour ${_authService.currentUser?.prenom ?? _authService.currentUser?.nom} !',
                style: AppStyles.heading3.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppStyles.paddingXL),

              // Grille de modules
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Wrap(
                  spacing: AppStyles.paddingL,
                  runSpacing: AppStyles.paddingL,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildModuleCard(
                      'Vente',
                      Icons.point_of_sale,
                      AppColors.vente,
                      'vente',
                    ),
                    _buildModuleCard(
                      'Produits',
                      Icons.inventory,
                      AppColors.produits,
                      'produits',
                    ),
                    _buildModuleCard(
                      'Stock',
                      Icons.warehouse,
                      AppColors.stock,
                      'stock',
                    ),
                    _buildModuleCard(
                      'Clients',
                      Icons.people,
                      AppColors.clients,
                      'clients',
                    ),
                    _buildModuleCard(
                      'Rapports',
                      Icons.analytics,
                      AppColors.rapports,
                      'rapports',
                    ),
                    _buildModuleCard(
                      'Paramètres',
                      Icons.settings,
                      AppColors.parametres,
                      'parametres',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.paddingXL * 2),

              // Info version
              Text(
                'Version ${AppConstants.appVersion}',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construire une carte de module
  Widget _buildModuleCard(
    String title,
    IconData icon,
    Color color,
    String moduleKey,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentModule = moduleKey;
        });
      },
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          boxShadow: AppStyles.shadowMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: AppStyles.paddingM),
            Text(
              title,
              style: AppStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Construire un placeholder pour un module
  Widget _buildPlaceholder(String title, IconData icon) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppStyles.paddingL),
            Text(
              title,
              style: AppStyles.heading2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppStyles.paddingM),
            Text(
              'Ce module sera disponible prochainement',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppStyles.paddingXL),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentModule = 'dashboard';
                });
              },
              icon: const Icon(Icons.home),
              label: const Text('Retour au tableau de bord'),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtenir le titre du module actuel
  String _getModuleTitle() {
    switch (_currentModule) {
      case 'dashboard':
        return 'Tableau de bord';
      case 'vente':
        return 'Vente';
      case 'produits':
        return 'Produits';
      case 'stock':
        return 'Stock';
      case 'clients':
        return 'Clients';
      case 'rapports':
        return 'Rapports';
      case 'fournisseurs':
        return 'Fournisseurs';
      case 'parametres':
        return 'Paramètres';
      default:
        return AppConstants.appName;
    }
  }

  /// Obtenir le libellé du rôle
  String _getRoleLabel(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Administrateur';
      case AppConstants.roleGerant:
        return 'Gérant';
      case AppConstants.roleCaissier:
        return 'Caissier';
      case AppConstants.roleStockiste:
        return 'Stockiste';
      default:
        return role;
    }
  }

  /// Déconnexion
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }
}
