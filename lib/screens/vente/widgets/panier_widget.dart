import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartpos_pro/core/constants/app_constants.dart';
import 'package:smartpos_pro/models/client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente_provider.dart';
import '../dialogs/paiement_dialog.dart';
import '../../../core/services/auth_service.dart';

/// Widget du panier
class PanierWidget extends StatelessWidget {
  const PanierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Header du panier
          _buildHeader(context),

          // Liste des articles
          Expanded(
            child: Consumer<VenteProvider>(
              builder: (context, venteProvider, child) {
                if (venteProvider.panierVide) {
                  return _buildPanierVide();
                }

                return _buildListePanier(venteProvider);
              },
            ),
          ),

          // Footer avec totaux et paiement
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.vente,
        boxShadow: AppStyles.shadowLight,
      ),
      child: Consumer<VenteProvider>(
        builder: (context, venteProvider, child) {
          return Row(
            children: [
              const Icon(Icons.shopping_cart, color: AppColors.textLight),
              const SizedBox(width: AppStyles.paddingM),
              Expanded(
                child: Text(
                  'Panier (${venteProvider.nombreArticles} articles)',
                  style: AppStyles.heading4.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              if (!venteProvider.panierVide)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.textLight,
                  ),
                  tooltip: 'Vider le panier',
                  onPressed: () => _confirmerViderPanier(context),
                ),
            ],
          );
        },
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
            'Ajoutez des produits pour commencer',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListePanier(VenteProvider venteProvider) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      itemCount: venteProvider.panier.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final ligne = venteProvider.panier[index];

        return Dismissible(
          key: Key('ligne_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppStyles.paddingM),
            color: AppColors.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            venteProvider.supprimerLigne(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ligne.nomProduit,
                        style: AppStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppStyles.paddingXS),
                      Text(
                        Formatters.formatDevise(ligne.prixUnitaireTTC),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppStyles.paddingM),

                // Contrôles de quantité
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () => venteProvider.diminuerQuantite(index),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        alignment: Alignment.center,
                        child: Text(
                          '${ligne.quantite.toInt()}',
                          style: AppStyles.labelLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => venteProvider.augmenterQuantite(index),
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

                // Bouton supprimer
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  tooltip: 'Supprimer',
                  onPressed: () {
                    context.read<VenteProvider>().supprimerLigne(index);
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),

                const SizedBox(width: AppStyles.paddingS),

                // Total de la ligne
                Text(
                  Formatters.formatDevise(ligne.totalTTC),
                  style: AppStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppStyles.shadowMedium,
      ),
      child: Consumer<VenteProvider>(
        builder: (context, venteProvider, child) {
          // Afficher détails TVA si facture demandée
          final afficherDetailTVA = venteProvider.genererFacture;

          return Column(
            children: [
              // Totaux
              Padding(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                child: Column(
                  children: [
                    // Afficher HT et TVA uniquement si facture demandée
                    if (afficherDetailTVA) ...[
                      _buildTotalRow(
                        'Sous-total HT',
                        venteProvider.sousTotal,
                        isSubtotal: true,
                      ),
                      const SizedBox(height: AppStyles.paddingS),
                      _buildTotalRow(
                        'TVA',
                        venteProvider.totalTVA,
                        isSubtotal: true,
                      ),
                      const Divider(height: AppStyles.paddingL),
                    ],

                    // Total TTC toujours affiché
                    _buildTotalRow(
                      afficherDetailTVA ? 'TOTAL TTC' : 'TOTAL',
                      venteProvider.totalTTC,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                child: Column(
                  children: [
                    // Bouton sélectionner client (toujours visible)
                    if (venteProvider.clientSelectionne == null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _selectionnerClient(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text(
                            'Ajouter un client (points fidélité)',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppStyles.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusM,
                          ),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: AppColors.primary),
                            const SizedBox(width: AppStyles.paddingS),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    venteProvider.clientSelectionne!.nomComplet,
                                    style: AppStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Points fidélité activés',
                                    style: AppStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                venteProvider.selectionnerClient(null);
                                venteProvider.toggleFacture(false);
                              },
                            ),
                          ],
                        ),
                      ),

                    // Checkbox "Générer une facture" (visible seulement si client sélectionné)
                    if (venteProvider.clientSelectionne != null) ...[
                      const SizedBox(height: AppStyles.paddingM),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusM,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 20,
                                color:
                                    venteProvider.genererFacture
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppStyles.paddingS),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Générer une facture',
                                      style: AppStyles.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Avec détails TVA pour le client',
                                      style: AppStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: venteProvider.genererFacture,
                          onChanged: (value) {
                            venteProvider.toggleFacture(value ?? false);
                          },
                          activeColor: AppColors.success,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppStyles.paddingM),

                    // Boutons remises (si panier non vide)
                    if (!venteProvider.panierVide) ...[
                      Row(
                        children: [
                          // Remise globale
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _appliquerRemiseGlobale(context),
                              icon: const Icon(Icons.discount, size: 18),
                              label: Text(
                                venteProvider.remiseGlobale > 0
                                    ? 'Remise: ${Formatters.formatDevise(venteProvider.remiseGlobale)}'
                                    : 'Remise globale',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    venteProvider.remiseGlobale > 0
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppStyles.paddingS),

                          // Annuler remise
                          if (venteProvider.remiseGlobale > 0)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Annuler la remise',
                              onPressed: () {
                                venteProvider.appliquerRemiseGlobale(0);
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: AppStyles.paddingM),
                    ],

                    // Bouton Payer
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed:
                            venteProvider.panierVide
                                ? null
                                : () => _ouvrirPaiement(context),
                        icon: const Icon(Icons.payment),
                        label: Text(
                          venteProvider.genererFacture
                              ? 'ÉMETTRE FACTURE'
                              : 'PAYER',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textLight,
                          textStyle: AppStyles.heading4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppStyles.paddingM),

                    // Bouton Mettre en attente
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            venteProvider.panierVide
                                ? null
                                : () => _mettreEnAttente(context),
                        icon: const Icon(Icons.pending_actions),
                        label: const Text('Mettre en attente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _appliquerRemiseGlobale(BuildContext context) {
    final venteProvider = context.read<VenteProvider>();
    final remiseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String typeRemise = 'montant'; // 'montant' ou 'pourcentage'

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Remise globale'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total avant remise: ${Formatters.formatDevise(venteProvider.totalAvantRemise)}',
                      style: AppStyles.labelLarge,
                    ),

                    const SizedBox(height: AppStyles.paddingL),

                    // Type de remise
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

                    // Champ montant/pourcentage
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
                        suffixText:
                            typeRemise == 'montant'
                                ? AppConstants.deviseSymbole
                                : '%',
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      remiseController.dispose(); // ← ICI c'est OK
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
                        remiseMontant =
                            venteProvider.totalAvantRemise * (valeur / 100);
                      } else {
                        if (valeur > venteProvider.totalAvantRemise) {
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

                      venteProvider.appliquerRemiseGlobale(remiseMontant);
                      remiseController.dispose(); // ← ICI c'est OK aussi
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

  Widget _buildTotalRow(
    String label,
    double montant, {
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? AppStyles.heading3
                  : AppStyles.bodyLarge.copyWith(
                    color:
                        isSubtotal
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                  ),
        ),
        Text(
          Formatters.formatDevise(montant),
          style:
              isTotal
                  ? AppStyles.prixLarge
                  : AppStyles.heading4.copyWith(
                    color:
                        isSubtotal
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                  ),
        ),
      ],
    );
  }

  void _selectionnerClient(BuildContext context) {
    // TODO: Implémenter la sélection de client
    // Pour l'instant, on simule avec un dialog simple
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sélectionner un client'),
            content: const Text(
              'La sélection de client sera disponible après '
              'l\'implémentation du module Clients.\n\n'
              'Pour tester, nous allons créer un client temporaire.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Créer un client temporaire pour test
                  final clientTemp = Client(
                    id: 1,
                    codeClient: 'CLI-00001',
                    nom: 'Client',
                    prenom: 'Test',
                    typeClient: 'professionnel',
                  );
                  context.read<VenteProvider>().selectionnerClient(clientTemp);
                  Navigator.pop(context);
                },
                child: const Text('Client Test'),
              ),
            ],
          ),
    );
  }

  void _confirmerViderPanier(BuildContext context) {
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
                  context.read<VenteProvider>().viderPanier();
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

  void _ouvrirPaiement(BuildContext context) {
    showDialog(context: context, builder: (context) => const PaiementDialog());
  }

  void _mettreEnAttente(BuildContext context) async {
    try {
      final venteProvider = context.read<VenteProvider>();
      final authService = AuthService.instance;

      await venteProvider.mettreEnAttente(
        utilisateurId: authService.currentUser?.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vente mise en attente'),
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
}
