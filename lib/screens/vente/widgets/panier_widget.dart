import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos_pro/core/services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ligne_vente.dart';
import '../../../providers/vente/vente_providers.dart';
import '../dialogs/paiement_dialog.dart';

/// Widget du panier de vente
class PanierWidget extends ConsumerWidget {
  const PanierWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panier = ref.watch(panierProvider);
    final totalTTC = ref.watch(totalTTCProvider);
    final totalHT = ref.watch(totalHTProvider);
    final totalTVA = ref.watch(totalTVAProvider);
    final nombreArticles = ref.watch(nombreArticlesProvider);
    final remiseGlobale = ref.watch(remiseGlobaleProvider);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context, ref, nombreArticles),
          Expanded(
            child:
                panier.isEmpty
                    ? _buildPanierVide()
                    : _buildListeArticles(context, ref, panier),
          ),
          _buildTotaux(
            context,
            ref,
            totalHT,
            totalTVA,
            totalTTC,
            remiseGlobale,
          ),
          _buildFooter(context, ref, panier, totalTTC),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int nombreArticles) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: AppColors.textLight, size: 24),
          const SizedBox(width: AppStyles.paddingS),
          Text(
            'Panier ($nombreArticles article${nombreArticles > 1 ? 's' : ''})',
            style: AppStyles.heading3.copyWith(color: AppColors.textLight),
          ),
          const Spacer(),
          if (nombreArticles > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.textLight,
              tooltip: 'Vider le panier',
              onPressed: () => _viderPanier(context, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildPanierVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppStyles.paddingL),
          Text(
            'Panier vide',
            style: AppStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppStyles.paddingS),
          Text(
            'Scannez ou ajoutez des produits',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeArticles(
    BuildContext context,
    WidgetRef ref,
    List<LigneVente> panier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      itemCount: panier.length,
      itemBuilder: (context, index) {
        final ligne = panier[index];
        return _buildLignePanier(context, ref, ligne, index);
      },
    );
  }

  Widget _buildLignePanier(
    BuildContext context,
    WidgetRef ref,
    LigneVente ligne,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingS),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingS),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ligne.nomProduit,
                    style: AppStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    Formatters.formatDevise(ligne.prixUnitaireTTC),
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      ref
                          .read(panierProvider.notifier)
                          .modifierQuantite(index, ligne.quantite - 1);
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      ligne.quantite.toInt().toString(),
                      textAlign: TextAlign.center,
                      style: AppStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      ref
                          .read(panierProvider.notifier)
                          .modifierQuantite(index, ligne.quantite + 1);
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppStyles.paddingS),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              tooltip: 'Supprimer',
              onPressed: () {
                ref.read(panierProvider.notifier).supprimerLigne(index);
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: AppStyles.paddingS),
            Text(
              Formatters.formatDevise(ligne.totalTTC),
              style: AppStyles.prixMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TOTAUX ====================

  Widget _buildTotaux(
    BuildContext context,
    WidgetRef ref,
    double totalHT,
    double totalTVA,
    double totalTTC,
    double remiseGlobale,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // ❌ SUPPRIMER l'affichage de HT et TVA ici
          // On n'affiche QUE le total TTC

          // Remise globale
          if (remiseGlobale > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Remise globale',
                      style: AppStyles.labelMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppStyles.paddingS),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: AppColors.error,
                      tooltip: 'Annuler la remise',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      onPressed: () {
                        ref.read(remiseGlobaleProvider.notifier).annuler();
                      },
                    ),
                  ],
                ),
                Text(
                  '- ${Formatters.formatDevise(remiseGlobale)}',
                  style: AppStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingS),
          ],

          // Bouton Remise
          if (ref.watch(panierProvider).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.paddingM),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _appliquerRemiseGlobale(context, ref),
                  icon: const Icon(Icons.discount, size: 18),
                  label: const Text('Remise globale'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                  ),
                ),
              ),
            ),

          const Divider(height: AppStyles.paddingL),

          // ✅ UNIQUEMENT le Total TTC (sans HT ni TVA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: AppStyles.heading2),
              Text(
                Formatters.formatDevise(totalTTC),
                style: AppStyles.prixLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== FOOTER ====================

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    List<LigneVente> panier,
    double totalTTC,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  panier.isEmpty ? null : () => _mettreEnAttente(context, ref),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingM,
                ),
              ),
              child: const Text('Mettre en attente'),
            ),
          ),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: panier.isEmpty ? null : () => _ouvrirPaiement(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingM,
                ),
              ),
              child: const Text(
                'PAYER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _appliquerRemiseGlobale(BuildContext context, WidgetRef ref) {
    final totalAvantRemise =
        ref.read(totalHTProvider) +
        ref.read(totalTVAProvider) +
        ref.read(remiseGlobaleProvider);

    final remiseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String typeRemise = 'montant';

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Remise globale'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total avant remise: ${Formatters.formatDevise(totalAvantRemise)}',
                      style: AppStyles.labelLarge,
                    ),
                    const SizedBox(height: AppStyles.paddingL),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'montant',
                          label: Text('Montant'),
                          icon: Icon(Icons.attach_money, size: 16),
                        ),
                        ButtonSegment(
                          value: 'pourcentage',
                          label: Text('Pourcentage'),
                          icon: Icon(Icons.percent, size: 16),
                        ),
                      ],
                      selected: {typeRemise},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          typeRemise = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: AppStyles.paddingM),
                    TextField(
                      controller: remiseController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            typeRemise == 'montant'
                                ? 'Montant de la remise'
                                : 'Pourcentage',
                        suffixText: typeRemise == 'montant' ? 'DA' : '%',
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      remiseController.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final valeur = double.tryParse(
                        remiseController.text.replaceAll(',', '.'),
                      );

                      if (valeur == null || valeur <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Valeur invalide'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      double remiseMontant;
                      if (typeRemise == 'pourcentage') {
                        if (valeur > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le pourcentage ne peut pas dépasser 100%',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        remiseMontant = totalAvantRemise * (valeur / 100);
                      } else {
                        if (valeur > totalAvantRemise) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La remise ne peut pas dépasser le total',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        remiseMontant = valeur;
                      }

                      ref
                          .read(remiseGlobaleProvider.notifier)
                          .appliquer(remiseMontant);
                      remiseController.dispose();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Appliquer'),
                  ),
                ],
              ),
        );
      },
    );
  }

  void _viderPanier(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Vider le panier'),
            content: const Text('Voulez-vous vraiment vider le panier ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(panierProvider.notifier).vider();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Vider'),
              ),
            ],
          ),
    );
  }

  void _mettreEnAttente(BuildContext context, WidgetRef ref) {
    final panier = ref.read(panierProvider);

    if (panier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le panier est vide'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();

        return AlertDialog(
          title: const Text('Mettre en attente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette vente sera mise en attente et pourra être reprise plus tard.',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: AppStyles.paddingM),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Ex: Client au téléphone',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                notesController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userId = AuthService.instance.currentUser?.id ?? 1;

                  await ref
                      .read(venteAttenteProvider.notifier)
                      .mettreEnAttente(
                        utilisateurId: userId,
                        notes:
                            notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                      );

                  notesController.dispose();

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vente mise en attente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  notesController.dispose();
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
                backgroundColor: AppColors.warning,
              ),
              child: const Text('Mettre en attente'),
            ),
          ],
        );
      },
    );
  }

  void _ouvrirPaiement(BuildContext context) {
    showDialog(context: context, builder: (context) => const PaiementDialog());
  }
}
