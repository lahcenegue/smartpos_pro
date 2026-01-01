import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente/vente_providers.dart';
import '../../../models/vente.dart';
import 'detail_vente_dialog.dart';

class HistoriqueVentesDialog extends ConsumerStatefulWidget {
  const HistoriqueVentesDialog({super.key});

  @override
  ConsumerState<HistoriqueVentesDialog> createState() =>
      _HistoriqueVentesDialogState();
}

class _HistoriqueVentesDialogState
    extends ConsumerState<HistoriqueVentesDialog> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _statutFiltre = 'tous';

  @override
  void initState() {
    super.initState();
    // Par défaut : derniers 7 jours
    final maintenant = DateTime.now();
    _dateFin = maintenant;
    _dateDebut = maintenant.subtract(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    final historiqueProvider = historiqueVentesProvider(
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      statut: _statutFiltre,
    );

    final ventesAsync = ref.watch(historiqueProvider);

    return Dialog(
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(AppStyles.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: AppStyles.paddingM),
                Text('Historique des ventes', style: AppStyles.heading2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualiser',
                  onPressed: () {
                    ref.invalidate(historiqueProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(height: AppStyles.paddingL),

            // Filtres
            _buildFiltres(),

            const SizedBox(height: AppStyles.paddingM),

            // Liste
            Expanded(
              child: ventesAsync.when(
                data: (ventes) {
                  if (ventes.isEmpty) {
                    return _buildVide();
                  }

                  return _buildListe(ventes);
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

            // Footer - Statistiques
            _buildFooterStats(ventesAsync.value ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltres() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        child: Row(
          children: [
            // Filtre date début
            Expanded(
              child: InkWell(
                onTap: () => _selectionnerDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date début',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateDebut != null
                        ? Formatters.formatDate(_dateDebut!)
                        : 'Sélectionner',
                    style: AppStyles.bodyMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppStyles.paddingM),

            // Filtre date fin
            Expanded(
              child: InkWell(
                onTap: () => _selectionnerDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date fin',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateFin != null
                        ? Formatters.formatDate(_dateFin!)
                        : 'Sélectionner',
                    style: AppStyles.bodyMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppStyles.paddingM),

            // Filtre statut
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _statutFiltre,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: const [
                  DropdownMenuItem(value: 'tous', child: Text('Tous')),
                  DropdownMenuItem(value: 'terminee', child: Text('Terminées')),
                  DropdownMenuItem(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(value: 'annulee', child: Text('Annulées')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statutFiltre = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectionnerDate(bool isDebut) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          isDebut
              ? (_dateDebut ?? DateTime.now())
              : (_dateFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (date != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = date;
        } else {
          _dateFin = date;
        }
      });
    }
  }

  Widget _buildVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppStyles.paddingM),
          Text(
            'Aucune vente trouvée',
            style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildListe(List<Vente> ventes) {
    return ListView.builder(
      itemCount: ventes.length,
      itemBuilder: (context, index) {
        final vente = ventes[index];
        return _buildVenteCard(vente);
      },
    );
  }

  Widget _buildVenteCard(Vente vente) {
    Color statutColor;
    IconData statutIcon;
    String statutLabel;

    switch (vente.statut) {
      case 'terminee':
        statutColor = AppColors.success;
        statutIcon = Icons.check_circle;
        statutLabel = 'Terminée';
        break;
      case 'en_attente':
        statutColor = AppColors.warning;
        statutIcon = Icons.pending;
        statutLabel = 'En attente';
        break;
      case 'annulee':
        statutColor = AppColors.error;
        statutIcon = Icons.cancel;
        statutLabel = 'Annulée';
        break;
      default:
        statutColor = AppColors.textSecondary;
        statutIcon = Icons.help;
        statutLabel = vente.statut;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statutColor.withOpacity(0.2),
          child: Icon(statutIcon, color: statutColor),
        ),
        title: Row(
          children: [
            Text(
              vente.numeroFacture,
              style: AppStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppStyles.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statutColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Text(
                statutLabel,
                style: AppStyles.labelSmall.copyWith(
                  color: statutColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.formatDateTime(vente.dateVente)),
            Text('${vente.lignes.length} article(s) • ${vente.modePaiement}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatters.formatDevise(vente.montantTTC),
              style: AppStyles.prixLarge,
            ),
            const SizedBox(width: AppStyles.paddingM),
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'Voir détail',
              onPressed: () => _voirDetail(vente),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterStats(List<Vente> ventes) {
    final ventesTerminees =
        ventes.where((v) => v.statut == 'terminee').toList();
    final totalCA = ventesTerminees.fold<double>(
      0,
      (sum, v) => sum + v.montantTTC,
    );

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total ventes',
            '${ventes.length}',
            Icons.receipt_long,
          ),
          _buildStatItem(
            'Terminées',
            '${ventesTerminees.length}',
            Icons.check_circle,
          ),
          _buildStatItem(
            'Chiffre d\'affaires',
            Formatters.formatDevise(totalCA),
            Icons.attach_money,
          ),
          _buildStatItem(
            'Panier moyen',
            ventesTerminees.isEmpty
                ? '0,00 DA'
                : Formatters.formatDevise(totalCA / ventesTerminees.length),
            Icons.shopping_basket,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppStyles.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _voirDetail(Vente vente) {
    showDialog(
      context: context,
      builder: (context) => DetailVenteDialog(venteId: vente.id!),
    );
  }
}
