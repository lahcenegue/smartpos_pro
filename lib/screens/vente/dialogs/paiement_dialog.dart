import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/auth_service.dart';
import '../../../providers/vente_provider.dart';
import '../../../models/vente.dart';
import '../../../core/services/print_service.dart';

/// Dialog de paiement
class PaiementDialog extends StatefulWidget {
  const PaiementDialog({super.key});

  @override
  State<PaiementDialog> createState() => _PaiementDialogState();
}

class _PaiementDialogState extends State<PaiementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _montantEspecesController = TextEditingController();
  final _montantCarteController = TextEditingController();
  final _montantChequeController = TextEditingController();

  String _modePaiement = AppConstants.paiementEspeces;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _calculerMontantParDefaut();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _montantEspecesController.dispose();
    _montantCarteController.dispose();
    _montantChequeController.dispose();
    super.dispose();
  }

  void _calculerMontantParDefaut() {
    final venteProvider = context.read<VenteProvider>();
    final total = venteProvider.totalTTC;

    // Arrondir au multiple de 10 supérieur pour les espèces
    if (_modePaiement == AppConstants.paiementEspeces) {
      final montantArrondi = (total / 10).ceil() * 10;
      _montantController.text = montantArrondi.toString();
    } else {
      _montantController.text = total.toStringAsFixed(2);
    }
  }

  void _onModePaiementChanged(String? mode) {
    if (mode == null) return;

    setState(() {
      _modePaiement = mode;
    });

    _calculerMontantParDefaut();
  }

  // Dans _validerPaiement(), ajoute ce debug AVANT finaliserVente
  Future<void> _validerPaiement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final venteProvider = context.read<VenteProvider>();
      final authService = AuthService.instance;

      // 🔍 DEBUG : Afficher les infos
      print('=== DEBUG VENTE ===');
      print('Client ID: ${venteProvider.clientSelectionne?.id}');
      print('Utilisateur ID: ${authService.currentUser?.id}');
      print('Panier vide: ${venteProvider.panierVide}');
      print('Nombre lignes: ${venteProvider.panier.length}');
      print('Générer facture: ${venteProvider.genererFacture}');
      print('==================');

      double montantPaye = 0;
      double montantEspeces = 0;
      double montantCarte = 0;
      double montantCheque = 0;

      if (_modePaiement == AppConstants.paiementMixte) {
        montantEspeces =
            double.tryParse(
              _montantEspecesController.text.replaceAll(',', '.'),
            ) ??
            0;
        montantCarte =
            double.tryParse(
              _montantCarteController.text.replaceAll(',', '.'),
            ) ??
            0;
        montantCheque =
            double.tryParse(
              _montantChequeController.text.replaceAll(',', '.'),
            ) ??
            0;
        montantPaye = montantEspeces + montantCarte + montantCheque;
      } else {
        montantPaye =
            double.tryParse(_montantController.text.replaceAll(',', '.')) ?? 0;
      }

      // Finaliser la vente
      final vente = await venteProvider.finaliserVente(
        modePaiement: _modePaiement,
        montantPaye: montantPaye,
        montantEspeces: montantEspeces,
        montantCarte: montantCarte,
        montantCheque: montantCheque,
        utilisateurId: authService.currentUser?.id,
      );

      if (mounted) {
        Navigator.of(context).pop();
        _afficherRecapitulatif(vente);
      }
    } catch (e) {
      print('=== ERREUR COMPLÈTE ===');
      print(e);
      print('=======================');

      if (mounted) {
        setState(() => _isProcessing = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _afficherRecapitulatif(Vente vente) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 32),
                const SizedBox(width: AppStyles.paddingM),
                Text(vente.estFacture ? 'Facture émise' : 'Vente enregistrée'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vente.estFacture ? "N° Facture" : "N° Ticket"}: ${vente.numeroFacture}',
                  style: AppStyles.labelLarge,
                ),
                const SizedBox(height: AppStyles.paddingM),

                if (vente.estFacture) ...[
                  Text(
                    'Sous-total HT: ${Formatters.formatDevise(vente.montantHT)}',
                  ),
                  Text('TVA: ${Formatters.formatDevise(vente.montantTVA)}'),
                ],

                Text('Total: ${Formatters.formatDevise(vente.montantTTC)}'),
                Text('Payé: ${Formatters.formatDevise(vente.montantPaye)}'),

                if (vente.montantRendu > 0)
                  Text(
                    'Rendu: ${Formatters.formatDevise(vente.montantRendu)}',
                    style: AppStyles.heading3.copyWith(
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Imprimer selon le type de document
                    if (vente.estFacture) {
                      await PrintService.instance.imprimerFacture(vente);
                    } else {
                      await PrintService.instance.imprimerTicket(vente);
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${vente.estFacture ? "Facture" : "Ticket"} imprimé',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur d\'impression: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.print),
                label: Text(
                  vente.estFacture ? 'Imprimer Facture' : 'Imprimer Ticket',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppStyles.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Récapitulatif
                      _buildRecapitulatif(),

                      const SizedBox(height: AppStyles.paddingXL),

                      // Mode de paiement
                      Text('Mode de paiement', style: AppStyles.heading4),
                      const SizedBox(height: AppStyles.paddingM),
                      _buildModesPaiement(),

                      const SizedBox(height: AppStyles.paddingXL),

                      // Champs de montant selon le mode
                      if (_modePaiement == AppConstants.paiementMixte)
                        _buildPaiementMixte()
                      else
                        _buildPaiementSimple(),

                      const SizedBox(height: AppStyles.paddingXL),

                      // Rendu monnaie
                      _buildRenduMonnaie(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer avec boutons
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
        color: AppColors.success,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppStyles.radiusM),
          topRight: Radius.circular(AppStyles.radiusM),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: AppColors.textLight, size: 32),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            child: Text(
              'Paiement',
              style: AppStyles.heading2.copyWith(color: AppColors.textLight),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.textLight),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapitulatif() {
    return Consumer<VenteProvider>(
      builder: (context, venteProvider, child) {
        final afficherDetailTVA = venteProvider.genererFacture;

        return Container(
          padding: const EdgeInsets.all(AppStyles.paddingM),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          child: Column(
            children: [
              _buildRecapRow('Articles', '${venteProvider.nombreArticles}'),

              // Afficher détails uniquement pour facture
              if (afficherDetailTVA) ...[
                const Divider(),
                _buildRecapRow(
                  'Sous-total HT',
                  Formatters.formatDevise(venteProvider.sousTotal),
                ),
                _buildRecapRow(
                  'TVA',
                  Formatters.formatDevise(venteProvider.totalTVA),
                ),
              ],

              const Divider(),
              _buildRecapRow(
                afficherDetailTVA ? 'TOTAL TTC' : 'TOTAL À PAYER',
                Formatters.formatDevise(venteProvider.totalTTC),
                isTotal: true,
              ),

              // Info document
              const Divider(),
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingS),
                decoration: BoxDecoration(
                  color: (venteProvider.genererFacture
                          ? AppColors.success
                          : AppColors.info)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      venteProvider.genererFacture
                          ? Icons.receipt_long
                          : Icons.receipt,
                      size: 16,
                      color:
                          venteProvider.genererFacture
                              ? AppColors.success
                              : AppColors.info,
                    ),
                    const SizedBox(width: AppStyles.paddingS),
                    Expanded(
                      child: Text(
                        venteProvider.genererFacture
                            ? 'Facture pour: ${venteProvider.clientSelectionne!.nomComplet}'
                            : venteProvider.clientSelectionne != null
                            ? 'Bon d\'achat avec points fidélité'
                            : 'Bon d\'achat',
                        style: AppStyles.labelSmall.copyWith(
                          color:
                              venteProvider.genererFacture
                                  ? AppColors.success
                                  : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecapRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppStyles.heading3 : AppStyles.bodyLarge,
          ),
          Text(
            value,
            style:
                isTotal
                    ? AppStyles.prixLarge.copyWith(fontSize: 24)
                    : AppStyles.heading4,
          ),
        ],
      ),
    );
  }

  Widget _buildModesPaiement() {
    return Wrap(
      spacing: AppStyles.paddingM,
      runSpacing: AppStyles.paddingM,
      children: [
        _buildModePaiementChip(
          AppConstants.paiementEspeces,
          'Espèces',
          Icons.payments,
          AppColors.paiementEspeces,
        ),
        _buildModePaiementChip(
          AppConstants.paiementCarte,
          'Carte',
          Icons.credit_card,
          AppColors.paiementCarte,
        ),
        _buildModePaiementChip(
          AppConstants.paiementCheque,
          'Chèque',
          Icons.receipt_long,
          AppColors.paiementCheque,
        ),
        _buildModePaiementChip(
          AppConstants.paiementMixte,
          'Mixte',
          Icons.auto_awesome_mosaic,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildModePaiementChip(
    String mode,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _modePaiement == mode;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: isSelected ? AppColors.textLight : color),
          const SizedBox(width: AppStyles.paddingS),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => _onModePaiementChanged(mode),
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textLight : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPaiementSimple() {
    final venteProvider = context.read<VenteProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Montant reçu', style: AppStyles.labelLarge),
        const SizedBox(height: AppStyles.paddingS),
        TextFormField(
          controller: _montantController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: AppConstants.deviseSymbole,
            prefixIcon: const Icon(Icons.attach_money),
          ),
          validator:
              (value) => Validators.validateMontant(
                value,
                min: venteProvider.totalTTC,
              ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppStyles.paddingM),

        // Boutons montants rapides
        Wrap(
          spacing: AppStyles.paddingS,
          runSpacing: AppStyles.paddingS,
          children: [
            _buildMontantRapideButton(500),
            _buildMontantRapideButton(1000),
            _buildMontantRapideButton(2000),
            _buildMontantRapideButton(5000),
            _buildMontantRapideButton(10000),
          ],
        ),
      ],
    );
  }

  Widget _buildMontantRapideButton(double montant) {
    return OutlinedButton(
      onPressed: () {
        _montantController.text = montant.toString();
        setState(() {});
      },
      child: Text(Formatters.formatDevise(montant)),
    );
  }

  Widget _buildPaiementMixte() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Répartition du paiement', style: AppStyles.labelLarge),
        const SizedBox(height: AppStyles.paddingM),

        // Espèces
        TextFormField(
          controller: _montantEspecesController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Espèces',
            suffixText: AppConstants.deviseSymbole,
            prefixIcon: Icon(Icons.payments, color: AppColors.paiementEspeces),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppStyles.paddingM),

        // Carte
        TextFormField(
          controller: _montantCarteController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Carte',
            suffixText: AppConstants.deviseSymbole,
            prefixIcon: Icon(Icons.credit_card, color: AppColors.paiementCarte),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppStyles.paddingM),

        // Chèque
        TextFormField(
          controller: _montantChequeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Chèque',
            suffixText: AppConstants.deviseSymbole,
            prefixIcon: Icon(
              Icons.receipt_long,
              color: AppColors.paiementCheque,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildRenduMonnaie() {
    final venteProvider = context.read<VenteProvider>();
    final total = venteProvider.totalTTC;

    double montantPaye = 0;
    if (_modePaiement == AppConstants.paiementMixte) {
      montantPaye =
          (double.tryParse(
                _montantEspecesController.text.replaceAll(',', '.'),
              ) ??
              0) +
          (double.tryParse(_montantCarteController.text.replaceAll(',', '.')) ??
              0) +
          (double.tryParse(
                _montantChequeController.text.replaceAll(',', '.'),
              ) ??
              0);
    } else {
      montantPaye =
          double.tryParse(_montantController.text.replaceAll(',', '.')) ?? 0;
    }

    final rendu = montantPaye - total;

    if (rendu <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.currency_exchange, color: AppColors.success, size: 32),
              const SizedBox(width: AppStyles.paddingM),
              Text(
                'Monnaie à rendre',
                style: AppStyles.heading4.copyWith(color: AppColors.success),
              ),
            ],
          ),
          Text(
            Formatters.formatDevise(rendu),
            style: AppStyles.prixLarge.copyWith(
              color: AppColors.success,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isProcessing ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingM,
                ),
              ),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _validerPaiement,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.check),
              label: Text(
                _isProcessing ? 'Traitement...' : 'Valider le paiement',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
