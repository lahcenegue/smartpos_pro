import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos_pro/core/utils/formatters.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/vente/vente_providers.dart';
import '../../repositories/produit_repository.dart';
import '../../models/produit.dart';
import 'widgets/panier_widget.dart';
import 'widgets/stats_temps_reel_widget.dart';
import 'dialogs/ventes_attente_dialog.dart';
import 'dialogs/historique_ventes_dialog.dart';

class VenteScreen extends ConsumerStatefulWidget {
  const VenteScreen({super.key});

  @override
  ConsumerState<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends ConsumerState<VenteScreen> {
  final ProduitRepository _produitRepo = ProduitRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Produit> _produits = [];
  List<Produit> _produitsAffiches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chargerProduits() async {
    setState(() => _isLoading = true);
    try {
      final produits = await _produitRepo.getTousProduits();
      setState(() {
        _produits = produits;
        _produitsAffiches = produits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _rechercherProduits(String query) {
    if (query.isEmpty) {
      setState(() => _produitsAffiches = _produits);
      return;
    }

    setState(() {
      _produitsAffiches =
          _produits.where((p) {
            return p.nom.toLowerCase().contains(query.toLowerCase()) ||
                (p.codeBarre?.toLowerCase().contains(query.toLowerCase()) ??
                    false);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caisse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: 'Ventes en attente',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VentesAttenteDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HistoriqueVentesDialog(),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Partie gauche - Produits (60%)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Stats temps réel
                Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingM),
                  child: const StatsTempsReelWidget(),
                ),

                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.paddingM,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _rechercherProduits('');
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      ),
                    ),
                    onChanged: _rechercherProduits,
                  ),
                ),

                const SizedBox(height: AppStyles.paddingM),

                // Grille de produits
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _produitsAffiches.isEmpty
                          ? Center(
                            child: Text(
                              'Aucun produit trouvé',
                              style: AppStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(AppStyles.paddingM),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: AppStyles.paddingM,
                                  mainAxisSpacing: AppStyles.paddingM,
                                ),
                            itemCount: _produitsAffiches.length,
                            itemBuilder: (context, index) {
                              final produit = _produitsAffiches[index];
                              return _buildProduitCard(produit);
                            },
                          ),
                ),
              ],
            ),
          ),

          // Partie droite - Panier (40%)
          const Expanded(flex: 4, child: PanierWidget()),
        ],
      ),
    );
  }

  Widget _buildProduitCard(Produit produit) {
    final enRupture = produit.stock <= 0;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap:
            enRupture
                ? null
                : () async {
                  try {
                    ref.read(panierProvider.notifier).ajouterProduit(produit);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${produit.nom} ajouté au panier'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                            bottom: 80,
                            left: 16,
                            right: 16,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                            bottom: 80,
                            left: 16,
                            right: 16,
                          ),
                        ),
                      );
                    }
                  }
                },
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.paddingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppStyles.paddingS),

              // Nom du produit
              Text(
                produit.nom,
                style: AppStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Prix
              Text(
                Formatters.formatDevise(produit.prixVente),
                style: AppStyles.prixMedium,
              ),

              // Stock
              Row(
                children: [
                  Icon(
                    enRupture ? Icons.warning : Icons.check_circle,
                    size: 16,
                    color: enRupture ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    enRupture ? 'Rupture' : 'Stock: ${produit.stock}',
                    style: AppStyles.labelSmall.copyWith(
                      color:
                          enRupture ? AppColors.error : AppColors.textSecondary,
                    ),
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
