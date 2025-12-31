import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';

/// Menu de navigation latéral
class AppDrawer extends StatelessWidget {
  final String currentModule;
  final Function(String) onModuleSelected;

  const AppDrawer({
    Key? key,
    required this.currentModule,
    required this.onModuleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.instance;
    final user = authService.currentUser;

    return Drawer(
      child: Column(
        children: [
          // En-tête du drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.paddingXL),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.backgroundLight,
                    child: Text(
                      user?.initiales ?? '?',
                      style: AppStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingM),
                  Text(
                    user?.nomComplet ?? 'Utilisateur',
                    style: AppStyles.heading4.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingXS),
                  Text(
                    _getRoleLabel(user?.role ?? ''),
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textLight.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des modules
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  'dashboard',
                  'Tableau de bord',
                  Icons.dashboard,
                  AppColors.primary,
                ),

                const Divider(height: 1),

                _buildMenuItem(
                  context,
                  'vente',
                  'Vente',
                  Icons.point_of_sale,
                  AppColors.vente,
                ),

                _buildMenuItem(
                  context,
                  'produits',
                  'Produits',
                  Icons.inventory,
                  AppColors.produits,
                ),

                _buildMenuItem(
                  context,
                  'stock',
                  'Stock',
                  Icons.warehouse,
                  AppColors.stock,
                ),

                _buildMenuItem(
                  context,
                  'clients',
                  'Clients',
                  Icons.people,
                  AppColors.clients,
                ),

                const Divider(height: 1),

                _buildMenuItem(
                  context,
                  'rapports',
                  'Rapports',
                  Icons.analytics,
                  AppColors.rapports,
                ),

                const Divider(height: 1),

                _buildMenuItem(
                  context,
                  'fournisseurs',
                  'Fournisseurs',
                  Icons.local_shipping,
                  AppColors.textSecondary,
                ),

                _buildMenuItem(
                  context,
                  'parametres',
                  'Paramètres',
                  Icons.settings,
                  AppColors.parametres,
                ),
              ],
            ),
          ),

          // Pied du drawer
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Construire un élément du menu
  Widget _buildMenuItem(
    BuildContext context,
    String moduleKey,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = currentModule == moduleKey;

    return ListTile(
      selected: isSelected,
      selectedTileColor: color.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? color : AppColors.textSecondary),
      title: Text(
        title,
        style: AppStyles.labelLarge.copyWith(
          color: isSelected ? color : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.chevron_right, color: color) : null,
      onTap: () => onModuleSelected(moduleKey),
    );
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
}
