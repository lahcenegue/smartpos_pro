import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente/vente_providers.dart';
import '../../../models/vente.dart';

class VentesAttenteDialog extends ConsumerWidget {
  const VentesAttenteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventesAsync = ref.watch(ventesEnAttenteProvider);

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(AppStyles.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.pending_actions, color: AppColors.primary),
                const SizedBox(width: AppStyles.paddingM),
                Text('Ventes en attente', style: AppStyles.heading2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualiser',
                  onPressed: () {
                    ref.invalidate(ventesEnAttenteProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(height: AppStyles.paddingL),

            // Liste
            Expanded(
              child: ventesAsync.when(
                data: (ventes) {
                  if (ventes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pending_actions_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: AppStyles.paddingM),
                          Text(
                            'Aucune vente en attente',
                            style: AppStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: ventes.length,
                    itemBuilder: (context, index) {
                      final vente = ventes[index];
                      return _buildVenteCard(context, ref, vente);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: AppStyles.paddingM),
                          Text(
                            'Erreur: $error',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenteCard(BuildContext context, WidgetRef ref, Vente vente) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.shopping_cart)),
                const SizedBox(width: AppStyles.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vente #${vente.id}',
                        style: AppStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Formatters.formatDateTime(vente.dateVente),
                        style: AppStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (vente.notes != null && vente.notes!.isNotEmpty)
                        Text(
                          vente.notes!,
                          style: AppStyles.labelSmall.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatDevise(vente.montantTTC),
                      style: AppStyles.prixLarge,
                    ),
                    Text(
                      '${vente.lignes.length} article(s)',
                      style: AppStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _supprimerVente(context, ref, vente),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
                const SizedBox(width: AppStyles.paddingS),
                ElevatedButton.icon(
                  onPressed: () => _chargerVente(context, ref, vente),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Charger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _chargerVente(BuildContext context, WidgetRef ref, Vente vente) async {
    try {
      await ref.read(venteAttenteProvider.notifier).charger(vente);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vente chargée dans le panier'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _supprimerVente(BuildContext context, WidgetRef ref, Vente vente) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la vente en attente'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette vente en attente ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(venteAttenteProvider.notifier)
                        .supprimer(vente.id!);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vente supprimée'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}
