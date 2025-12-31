import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/print_service.dart';
import '../../../repositories/vente_repository.dart';
import '../../../models/vente.dart';

/// Dialog pour afficher l'historique des ventes
class HistoriqueVentesDialog extends StatefulWidget {
  const HistoriqueVentesDialog({Key? key}) : super(key: key);

  @override
  State<HistoriqueVentesDialog> createState() => _HistoriqueVentesDialogState();
}

class _HistoriqueVentesDialogState extends State<HistoriqueVentesDialog> {
  final VenteRepository _venteRepo = VenteRepository();
  List<Vente> _ventes = [];
  bool _isLoading = true;

  // Filtres
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _filtreStatut = 'tous'; // 'tous', 'terminee', 'annulee'

  @override
  void initState() {
    super.initState();
    // Par défaut : ventes du jour
    _dateDebut = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    _dateFin = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    _chargerVentes();
  }

  /// Formater une date simplement
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _chargerVentes() async {
    setState(() => _isLoading = true);

    try {
      List<Vente> ventes;

      if (_dateDebut != null && _dateFin != null) {
        ventes = await _venteRepo.getVentesParPeriode(_dateDebut!, _dateFin!);
      } else {
        ventes = await _venteRepo.getToutesVentes(limit: 50);
      }

      // Filtrer par statut si nécessaire
      if (_filtreStatut != 'tous') {
        ventes = ventes.where((v) => v.statut == _filtreStatut).toList();
      }

      if (mounted) {
        setState(() {
          _ventes = ventes;
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

  Future<void> _reimprimer(Vente vente) async {
    try {
      if (vente.estFacture) {
        await PrintService.instance.imprimerFacture(vente);
      } else {
        await PrintService.instance.imprimerTicket(vente);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${vente.estFacture ? "Facture" : "Ticket"} réimprimé',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur d\'impression: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _selectionnerPeriode() async {
    final resultat = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder:
          (context) => _PeriodeDialog(dateDebut: _dateDebut, dateFin: _dateFin),
    );

    if (resultat != null) {
      setState(() {
        _dateDebut = resultat['debut'];
        _dateFin = resultat['fin'];
      });
      _chargerVentes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Filtres
            _buildFiltres(),

            // Liste des ventes
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _ventes.isEmpty
                      ? _buildEmptyState()
                      : _buildListeVentes(),
            ),

            // Footer avec stats
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppStyles.radiusM),
          topRight: Radius.circular(AppStyles.radiusM),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.textLight, size: 32),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            child: Text(
              'Historique des ventes',
              style: AppStyles.heading2.copyWith(color: AppColors.textLight),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textLight),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltres() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Bouton période
          OutlinedButton.icon(
            onPressed: _selectionnerPeriode,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _dateDebut != null && _dateFin != null
                  ? '${_formatDate(_dateDebut!)} - ${_formatDate(_dateFin!)}'
                  : 'Toutes les ventes',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(width: AppStyles.paddingM),

          // Filtre statut
          DropdownButton<String>(
            value: _filtreStatut,
            items: const [
              DropdownMenuItem(value: 'tous', child: Text('Toutes')),
              DropdownMenuItem(value: 'terminee', child: Text('Terminées')),
              DropdownMenuItem(value: 'annulee', child: Text('Annulées')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _filtreStatut = value);
                _chargerVentes();
              }
            },
          ),

          const Spacer(),

          // Nombre de résultats
          Text(
            '${_ventes.length} vente(s)',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppStyles.paddingL),
          Text(
            'Aucune vente trouvée',
            style: AppStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildListeVentes() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      itemCount: _ventes.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final vente = _ventes[index];
        return _buildVenteCard(vente);
      },
    );
  }

  Widget _buildVenteCard(Vente vente) {
    final Color statutColor =
        vente.statut == 'terminee'
            ? AppColors.success
            : vente.statut == 'annulee'
            ? AppColors.error
            : AppColors.warning;

    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statutColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          child: Icon(
            vente.estFacture ? Icons.receipt_long : Icons.receipt,
            color: statutColor,
          ),
        ),
        title: Row(
          children: [
            Text(
              vente.numeroFacture,
              style: AppStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppStyles.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statutColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Text(
                vente.statut.toUpperCase(),
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
            Text(_formatDate(vente.dateVente)),
            const SizedBox(height: 4),
            Text(
              '${vente.lignes.length} article(s) • ${Formatters.formatDevise(vente.montantTTC)}',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Réimprimer',
          onPressed: () => _reimprimer(vente),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Détails de paiement
                _buildDetailRow(
                  'Mode de paiement',
                  _getModePaiementLabel(vente.modePaiement),
                ),
                _buildDetailRow(
                  'Montant payé',
                  Formatters.formatDevise(vente.montantPaye),
                ),
                if (vente.montantRendu > 0)
                  _buildDetailRow(
                    'Rendu',
                    Formatters.formatDevise(vente.montantRendu),
                  ),

                const Divider(height: AppStyles.paddingL),

                // Articles
                Text(
                  'Articles',
                  style: AppStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppStyles.paddingS),
                ...vente.lignes.map((ligne) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppStyles.paddingS),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${ligne.quantite.toInt()}x ${ligne.nomProduit}',
                            style: AppStyles.bodyMedium,
                          ),
                        ),
                        Text(
                          Formatters.formatDevise(ligne.totalTTC),
                          style: AppStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyMedium),
          Text(
            value,
            style: AppStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final totalVentes = _ventes.fold<double>(
      0,
      (sum, vente) => sum + (vente.statut == 'terminee' ? vente.montantTTC : 0),
    );

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total des ventes terminées', style: AppStyles.heading4),
          Text(
            Formatters.formatDevise(totalVentes),
            style: AppStyles.prixLarge,
          ),
        ],
      ),
    );
  }

  String _getModePaiementLabel(String mode) {
    switch (mode) {
      case 'especes':
        return 'Espèces';
      case 'carte':
        return 'Carte bancaire';
      case 'cheque':
        return 'Chèque';
      case 'mixte':
        return 'Paiement mixte';
      default:
        return mode;
    }
  }
}

/// Dialog de sélection de période
class _PeriodeDialog extends StatefulWidget {
  final DateTime? dateDebut;
  final DateTime? dateFin;

  const _PeriodeDialog({this.dateDebut, this.dateFin});

  @override
  State<_PeriodeDialog> createState() => _PeriodeDialogState();
}

class _PeriodeDialogState extends State<_PeriodeDialog> {
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    _dateDebut = widget.dateDebut;
    _dateFin = widget.dateFin;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner une période'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Boutons période rapide
          Wrap(
            spacing: AppStyles.paddingS,
            children: [
              OutlinedButton(
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _dateDebut = now.copyWith(hour: 0, minute: 0);
                    _dateFin = now.copyWith(hour: 23, minute: 59);
                  });
                },
                child: const Text('Aujourd\'hui'),
              ),
              OutlinedButton(
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _dateDebut = now.subtract(const Duration(days: 7));
                    _dateFin = now;
                  });
                },
                child: const Text('7 derniers jours'),
              ),
              OutlinedButton(
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _dateDebut = DateTime(now.year, now.month, 1);
                    _dateFin = now;
                  });
                },
                child: const Text('Ce mois'),
              ),
            ],
          ),

          const SizedBox(height: AppStyles.paddingL),

          // Date début
          ListTile(
            title: const Text('Date début'),
            subtitle: Text(_formatDate(_dateDebut)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateDebut ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateDebut = date);
              }
            },
          ),

          // Date fin
          ListTile(
            title: const Text('Date fin'),
            subtitle: Text(_formatDate(_dateFin)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateFin ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateFin = date);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {'debut': _dateDebut, 'fin': _dateFin});
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
