import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../providers/vente/vente_providers.dart';
import '../../../models/vente.dart';

class DetailVenteDialog extends ConsumerWidget {
  final int venteId;

  const DetailVenteDialog({super.key, required this.venteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venteAsync = ref.watch(detailVenteProvider(venteId));

    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(AppStyles.paddingL),
        child: venteAsync.when(
          data: (vente) {
            if (vente == null) {
              return const Center(child: Text('Vente introuvable'));
            }
            return _buildContent(context, ref, vente);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur: $error')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Vente vente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Icon(
              vente.estFacture ? Icons.description : Icons.receipt,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppStyles.paddingM),
            Text(
              'Détail ${vente.estFacture ? "Facture" : "Ticket"}',
              style: AppStyles.heading2,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const Divider(height: AppStyles.paddingL),

        // Informations générales
        _buildInfosGenerales(vente),

        const SizedBox(height: AppStyles.paddingM),

        // Liste des articles
        Text('Articles', style: AppStyles.heading3),
        const SizedBox(height: AppStyles.paddingS),

        Expanded(
          child: Card(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppStyles.paddingS),
              itemCount: vente.lignes.length,
              itemBuilder: (context, index) {
                final ligne = vente.lignes[index];
                return ListTile(
                  title: Text(ligne.nomProduit),
                  subtitle: Text(
                    '${ligne.quantite.toInt()} x ${Formatters.formatDevise(ligne.prixUnitaireTTC)}',
                  ),
                  trailing: Text(
                    Formatters.formatDevise(ligne.totalTTC),
                    style: AppStyles.prixMedium,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppStyles.paddingM),

        // Totaux
        _buildTotaux(vente),

        const SizedBox(height: AppStyles.paddingL),

        // Actions
        _buildActions(context, ref, vente),
      ],
    );
  }

  Widget _buildInfosGenerales(Vente vente) {
    Color statutColor;
    String statutLabel;

    switch (vente.statut) {
      case 'terminee':
        statutColor = AppColors.success;
        statutLabel = 'Terminée';
        break;
      case 'en_attente':
        statutColor = AppColors.warning;
        statutLabel = 'En attente';
        break;
      case 'annulee':
        statutColor = AppColors.error;
        statutLabel = 'Annulée';
        break;
      default:
        statutColor = AppColors.textSecondary;
        statutLabel = vente.statut;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(vente.numeroFacture, style: AppStyles.heading3),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Text(
                    statutLabel,
                    style: AppStyles.labelMedium.copyWith(
                      color: statutColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Date', Formatters.formatDateTime(vente.dateVente)),
            _buildInfoRow('Mode de paiement', vente.modePaiement),
            _buildInfoRow(
              'Montant payé',
              Formatters.formatDevise(vente.montantPaye),
            ),
            if (vente.montantRendu > 0)
              _buildInfoRow(
                'Rendu',
                Formatters.formatDevise(vente.montantRendu),
              ),
            if (vente.statut == 'annulee') ...[
              const Divider(),
              _buildInfoRow(
                'Date annulation',
                vente.dateAnnulation != null
                    ? Formatters.formatDateTime(vente.dateAnnulation!)
                    : '-',
              ),
              _buildInfoRow('Motif', vente.motifAnnulation ?? '-'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotaux(Vente vente) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        child: Column(
          children: [
            if (vente.estFacture) ...[
              _buildTotalRow('Sous-total HT', vente.montantHT),
              _buildTotalRow('TVA', vente.montantTVA),
              const Divider(),
            ],
            if (vente.montantRemise > 0)
              _buildTotalRow(
                'Remise',
                vente.montantRemise,
                color: AppColors.success,
              ),
            _buildTotalRow('TOTAL TTC', vente.montantTTC, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double montant, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal
                    ? AppStyles.heading3
                    : AppStyles.labelMedium.copyWith(color: color),
          ),
          Text(
            Formatters.formatDevise(montant),
            style:
                isTotal
                    ? AppStyles.prixLarge.copyWith(color: AppColors.primary)
                    : AppStyles.prixMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Vente vente) {
    return Row(
      children: [
        // Annuler (seulement si terminée)
        if (vente.statut == 'terminee')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _annulerVente(context, ref, vente),
              icon: const Icon(Icons.cancel),
              label: const Text('Annuler la vente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingM,
                ),
              ),
            ),
          ),

        if (vente.statut == 'terminee')
          const SizedBox(width: AppStyles.paddingM),

        // Réimprimer
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _reimprimer(context, vente),
            icon: const Icon(Icons.print),
            label: const Text('Réimprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingM),
            ),
          ),
        ),
      ],
    );
  }

  void _annulerVente(BuildContext context, WidgetRef ref, Vente vente) {
    final motifController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Annuler la vente'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Êtes-vous sûr de vouloir annuler cette vente ?',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: AppStyles.paddingM),
                Text(
                  'Le stock sera restauré automatiquement.',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppStyles.paddingM),
                TextField(
                  controller: motifController,
                  decoration: const InputDecoration(
                    labelText: 'Motif d\'annulation',
                    hintText: 'Ex: Erreur de saisie',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  motifController.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Non, garder'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final motif = motifController.text.trim();

                  if (motif.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le motif est obligatoire'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  try {
                    final userId = AuthService.instance.currentUser?.id ?? 1;

                    await ref
                        .read(annulationVenteProvider.notifier)
                        .annuler(
                          venteId: vente.id!,
                          motif: motif,
                          utilisateurId: userId,
                        );

                    motifController.dispose();

                    if (context.mounted) {
                      Navigator.pop(context); // Fermer dialog motif
                      Navigator.pop(context); // Fermer dialog détail
                      Navigator.pop(context); // Fermer dialog historique

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vente annulée avec succès'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    motifController.dispose();
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
                child: const Text('Oui, annuler'),
              ),
            ],
          ),
    );
  }

  Future<void> _reimprimer(BuildContext context, Vente vente) async {
    try {
      final pdf =
          vente.estFacture
              ? await PrintService.instance.genererFacturePDF(vente)
              : await PrintService.instance.genererTicketPDF(vente);

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: vente.numeroFacture,
      );
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
}
