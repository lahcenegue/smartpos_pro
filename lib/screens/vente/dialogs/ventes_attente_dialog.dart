import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente_provider.dart';
import '../../../repositories/vente_repository.dart';
import '../../../models/vente.dart';

/// Dialog pour afficher et gérer les ventes en attente
class VentesAttenteDialog extends StatefulWidget {
  const VentesAttenteDialog({super.key});

  @override
  State<VentesAttenteDialog> createState() => _VentesAttenteDialogState();
}

class _VentesAttenteDialogState extends State<VentesAttenteDialog> {
  final VenteRepository _venteRepo = VenteRepository();
  List<Vente> _ventesEnAttente = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerVentesEnAttente();
  }

  // ← AJOUTER cette méthode
  /// Formater une date simplement (sans dépendance locale)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _chargerVentesEnAttente() async {
    setState(() => _isLoading = true);

    try {
      final ventes = await _venteRepo.getVentesEnAttente();

      if (mounted) {
        setState(() {
          _ventesEnAttente = ventes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur lors du chargement: $e');
      }
    }
  }

  Future<void> _chargerVente(Vente vente) async {
    try {
      final venteProvider = context.read<VenteProvider>();
      await venteProvider.chargerVenteEnAttente(vente);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vente ${vente.numeroFacture} chargée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors du chargement: $e');
      }
    }
  }

  Future<void> _supprimerVente(Vente vente) async {
    // Demander confirmation
    final confirme = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la vente'),
            content: Text(
              'Voulez-vous vraiment supprimer la vente ${vente.numeroFacture} ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirme == true) {
      try {
        await _venteRepo.supprimerVente(vente.id!);
        _chargerVentesEnAttente();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vente ${vente.numeroFacture} supprimée'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showError('Erreur lors de la suppression: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.radiusM),
                  topRight: Radius.circular(AppStyles.radiusM),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: AppColors.textLight,
                    size: 32,
                  ),
                  const SizedBox(width: AppStyles.paddingM),
                  Expanded(
                    child: Text(
                      'Ventes en attente (${_ventesEnAttente.length})',
                      style: AppStyles.heading2.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textLight),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _ventesEnAttente.isEmpty
                      ? _buildEmptyState()
                      : _buildListeVentes(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppStyles.paddingL),
          Text(
            'Aucune vente en attente',
            style: AppStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildListeVentes() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      itemCount: _ventesEnAttente.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final vente = _ventesEnAttente[index];
        return _buildVenteCard(vente);
      },
    );
  }

  Widget _buildVenteCard(Vente vente) {
    return Card(
      child: InkWell(
        onTap: () => _chargerVente(vente),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.paddingM),
          child: Row(
            children: [
              // Icône
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: AppColors.warning,
                ),
              ),

              const SizedBox(width: AppStyles.paddingM),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vente.numeroFacture,
                          style: AppStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppStyles.paddingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyles.paddingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusS,
                            ),
                          ),
                          child: Text(
                            'EN ATTENTE',
                            style: AppStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.paddingXS),
                    Text(
                      '${vente.lignes.length} article(s) • ${Formatters.formatDevise(vente.montantTTC)}',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingXS),
                    Text(
                      _formatDate(
                        vente.dateVente,
                      ), // ← UTILISER _formatDate au lieu de Formatters.formatDateTime
                      style: AppStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              Row(
                children: [
                  // Charger
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Charger',
                    color: AppColors.success,
                    onPressed: () => _chargerVente(vente),
                  ),

                  // Supprimer
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Supprimer',
                    color: AppColors.error,
                    onPressed: () => _supprimerVente(vente),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
