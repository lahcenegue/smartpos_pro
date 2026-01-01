import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../providers/vente/vente_providers.dart';
import '../../../models/vente.dart';

class PaiementDialog extends ConsumerStatefulWidget {
  const PaiementDialog({super.key});

  @override
  ConsumerState<PaiementDialog> createState() => _PaiementDialogState();
}

class _PaiementDialogState extends ConsumerState<PaiementDialog> {
  String _modePaiement = AppConstants.paiementEspeces;
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _montantEspecesController =
      TextEditingController();
  final TextEditingController _montantCarteController = TextEditingController();

  @override
  void dispose() {
    _montantController.dispose();
    _montantEspecesController.dispose();
    _montantCarteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    final totalTTC = ref.watch(totalTTCProvider);
    final totalHT = ref.watch(totalHTProvider);
    final totalTVA = ref.watch(totalTVAProvider);
    final nombreArticles = ref.watch(nombreArticlesProvider);

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppStyles.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.payment, color: AppColors.primary),
                const SizedBox(width: AppStyles.paddingM),
                Text('Paiement', style: AppStyles.heading2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(height: AppStyles.paddingL),

            // Récapitulatif
            _buildRecapitulatif(nombreArticles, totalHT, totalTVA, totalTTC),

            const SizedBox(height: AppStyles.paddingL),

            // Modes de paiement
            _buildModesPaiement(),

            const SizedBox(height: AppStyles.paddingL),

            // Montant selon le mode
            if (_modePaiement == AppConstants.paiementMixte)
              _buildPaiementMixte(totalTTC)
            else
              _buildMontantSimple(totalTTC),

            const SizedBox(height: AppStyles.paddingL),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _validerPaiement(context, totalTTC),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapitulatif(
    int nombreArticles,
    double totalHT,
    double totalTVA,
    double totalTTC,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Column(
        children: [
          _buildLigneRecap('Articles', '$nombreArticles'),
          const SizedBox(height: AppStyles.paddingS),
          const Divider(),
          _buildLigneRecap(
            'Total TTC',
            Formatters.formatDevise(totalTTC),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLigneRecap(String label, String valeur, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? AppStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)
                  : AppStyles.labelMedium,
        ),
        Text(
          valeur,
          style:
              isTotal
                  ? AppStyles.prixLarge.copyWith(color: AppColors.primary)
                  : AppStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildModesPaiement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode de paiement', style: AppStyles.labelLarge),
        const SizedBox(height: AppStyles.paddingM),
        Wrap(
          spacing: AppStyles.paddingM,
          children: [
            _buildModePaiementChip(
              AppConstants.paiementEspeces,
              Icons.money,
              'Espèces',
            ),
            _buildModePaiementChip(
              AppConstants.paiementCarte,
              Icons.credit_card,
              'Carte',
            ),
            _buildModePaiementChip(
              AppConstants.paiementCheque,
              Icons.receipt,
              'Chèque',
            ),
            _buildModePaiementChip(
              AppConstants.paiementMixte,
              Icons.payments,
              'Mixte',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModePaiementChip(String mode, IconData icon, String label) {
    final isSelected = _modePaiement == mode;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppStyles.paddingS),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _modePaiement = mode;
          _montantController.clear();
          _montantEspecesController.clear();
          _montantCarteController.clear();
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
    );
  }

  Widget _buildMontantSimple(double totalTTC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Montant reçu', style: AppStyles.labelLarge),
        const SizedBox(height: AppStyles.paddingM),
        TextField(
          controller: _montantController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: AppConstants.deviseSymbole,
            border: const OutlineInputBorder(),
            hintText: '0.00',
          ),
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: AppStyles.paddingM),
        _buildRenduMonnaie(totalTTC),
      ],
    );
  }

  Widget _buildPaiementMixte(double totalTTC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Répartition', style: AppStyles.labelLarge),
        const SizedBox(height: AppStyles.paddingM),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _montantEspecesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Espèces',
                  prefixText: AppConstants.deviseSymbole,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppStyles.paddingM),
            Expanded(
              child: TextField(
                controller: _montantCarteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Carte',
                  prefixText: AppConstants.deviseSymbole,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.paddingM),
        _buildRenduMonnaie(totalTTC),
      ],
    );
  }

  Widget _buildRenduMonnaie(double totalTTC) {
    final montantPaye = _calculerMontantPaye();
    final rendu = montantPaye - totalTTC;

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color:
            rendu < 0
                ? AppColors.error.withOpacity(0.1)
                : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            rendu < 0 ? 'Manquant' : 'Rendu',
            style: AppStyles.labelLarge.copyWith(
              color: rendu < 0 ? AppColors.error : AppColors.success,
            ),
          ),
          Text(
            Formatters.formatDevise(rendu.abs()),
            style: AppStyles.prixLarge.copyWith(
              color: rendu < 0 ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  double _calculerMontantPaye() {
    if (_modePaiement == AppConstants.paiementMixte) {
      final especes =
          double.tryParse(
            _montantEspecesController.text.replaceAll(',', '.'),
          ) ??
          0;
      final carte =
          double.tryParse(_montantCarteController.text.replaceAll(',', '.')) ??
          0;
      return especes + carte;
    } else {
      return double.tryParse(_montantController.text.replaceAll(',', '.')) ?? 0;
    }
  }

  Future<void> _validerPaiement(BuildContext context, double totalTTC) async {
    final montantPaye = _calculerMontantPaye();

    if (montantPaye < totalTTC) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant payé est insuffisant'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final userId = AuthService.instance.currentUser?.id ?? 1;

      final vente = await ref
          .read(venteFinalisationProvider.notifier)
          .finaliser(
            modePaiement: _modePaiement,
            montantPaye: montantPaye,
            utilisateurId: userId,
          );

      if (context.mounted) {
        Navigator.pop(context);
        _afficherRecapitulatif(context, vente);
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

  void _afficherRecapitulatif(BuildContext context, Vente vente) async {
    // Vérifier si une imprimante est disponible
    final imprimanteDisponible = await _verifierImprimante();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32,
                ),
                const SizedBox(width: AppStyles.paddingM),
                const Text('Vente enregistrée'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('N° ${vente.numeroFacture}', style: AppStyles.heading3),
                const SizedBox(height: AppStyles.paddingM),
                Text('Total: ${Formatters.formatDevise(vente.montantTTC)}'),
                Text('Payé: ${Formatters.formatDevise(vente.montantPaye)}'),
                if (vente.montantRendu > 0)
                  Text('Rendu: ${Formatters.formatDevise(vente.montantRendu)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),

              // Bouton Sauvegarder (optionnel)
              if (!imprimanteDisponible)
                ElevatedButton.icon(
                  onPressed: () => _sauvegarderPDF(context, vente),
                  icon: const Icon(Icons.save),
                  label: const Text('Sauvegarder PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                  ),
                ),

              // Bouton Imprimer (prioritaire si imprimante disponible)
              if (imprimanteDisponible)
                ElevatedButton.icon(
                  onPressed: () => _imprimerTicket(context, vente),
                  icon: const Icon(Icons.print),
                  label: Text(
                    'Imprimer ${vente.estFacture ? "Facture" : "Ticket"}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),

              // Bouton Aperçu (toujours disponible)
              ElevatedButton.icon(
                onPressed: () => _apercuPDF(context, vente),
                icon: const Icon(Icons.visibility),
                label: const Text('Aperçu'),
              ),
            ],
          ),
    );
  }

  /// Vérifier si une imprimante est disponible
  Future<bool> _verifierImprimante() async {
    try {
      final imprimantes = await Printing.listPrinters();
      return imprimantes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Imprimer directement le ticket
  Future<void> _imprimerTicket(BuildContext context, Vente vente) async {
    try {
      // Générer le PDF
      final pdf =
          vente.estFacture
              ? await PrintService.instance.genererFacturePDF(vente)
              : await PrintService.instance.genererTicketPDF(vente);

      // Sauvegarder automatiquement
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/SmartPOS');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final path = '${folder.path}/${vente.numeroFacture}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        // Afficher un message avec option d'ouvrir le fichier
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF généré: ${vente.numeroFacture}.pdf'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ouvrir dossier',
              textColor: Colors.white,
              onPressed: () async {
                await Process.run('explorer', [folder.path]);
              },
            ),
          ),
        );

        // Ouvrir automatiquement le PDF avec l'application par défaut
        await Process.run('cmd', ['/c', 'start', '', path]);
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

  /// Sauvegarder le PDF dans Documents
  Future<void> _sauvegarderPDF(BuildContext context, Vente vente) async {
    try {
      final pdf =
          vente.estFacture
              ? await PrintService.instance.genererFacturePDF(vente)
              : await PrintService.instance.genererTicketPDF(vente);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/SmartPOS/${vente.numeroFacture}.pdf';

      // Créer le dossier si nécessaire
      final folder = Directory('${directory.path}/SmartPOS');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF sauvegardé: $path'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ouvrir',
              textColor: Colors.white,
              onPressed: () async {
                await Process.run('explorer', [folder.path]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de sauvegarde: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Afficher l'aperçu PDF dans un viewer personnalisé
  Future<void> _apercuPDF(BuildContext context, Vente vente) async {
    try {
      // Générer le PDF
      final pdf =
          vente.estFacture
              ? await PrintService.instance.genererFacturePDF(vente)
              : await PrintService.instance.genererTicketPDF(vente);

      final pdfBytes = await pdf.save();

      if (context.mounted) {
        // Afficher dans un dialog avec PdfPreview
        showDialog(
          context: context,
          builder:
              (context) => Dialog(
                child: Container(
                  width: 800,
                  height: 600,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Aperçu - ${vente.numeroFacture}',
                            style: AppStyles.heading3,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Aperçu PDF
                      Expanded(
                        child: PdfPreview(
                          build: (format) => pdfBytes,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          allowPrinting: true,
                          allowSharing: true,
                          pdfFileName: vente.numeroFacture,
                        ),
                      ),
                    ],
                  ),
                ),
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
}
