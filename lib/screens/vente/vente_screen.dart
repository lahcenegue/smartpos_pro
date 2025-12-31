import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/vente_provider.dart';
import '../../models/produit.dart';
import 'dialogs/ventes_attente_dialog.dart';
import 'dialogs/historique_ventes_dialog.dart';
import 'widgets/produit_grid.dart';
import 'widgets/panier_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/categorie_chips.dart';

/// Écran principal de vente (caisse)
class VenteScreen extends StatefulWidget {
  const VenteScreen({super.key});

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _categorieSelectionnee;
  List<Produit> _produits = [];
  bool _isLoading = false;

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

  /// Charger tous les produits
  Future<void> _chargerProduits() async {
    setState(() => _isLoading = true);

    try {
      final venteProvider = context.read<VenteProvider>();
      final produits = await venteProvider.rechercherProduits('');

      if (mounted) {
        setState(() {
          _produits = produits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur lors du chargement des produits: $e');
      }
    }
  }

  /// Rechercher des produits
  Future<void> _rechercherProduits(String query) async {
    if (query.isEmpty) {
      _chargerProduits();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final venteProvider = context.read<VenteProvider>();
      final produits = await venteProvider.rechercherProduits(query);

      if (mounted) {
        setState(() {
          _produits = produits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur lors de la recherche: $e');
      }
    }
  }

  /// Filtrer par catégorie
  Future<void> _filtrerParCategorie(int? categorieId) async {
    setState(() {
      _categorieSelectionnee = categorieId;
      _isLoading = true;
    });

    try {
      final venteProvider = context.read<VenteProvider>();

      List<Produit> produits;
      if (categorieId == null) {
        produits = await venteProvider.rechercherProduits('');
      } else {
        produits = await venteProvider.getProduitsByCategorie(categorieId);
      }

      if (mounted) {
        setState(() {
          _produits = produits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur lors du filtrage: $e');
      }
    }
  }

  /// Ajouter un produit au panier
  Future<void> _ajouterAuPanier(Produit produit) async {
    try {
      final venteProvider = context.read<VenteProvider>();
      await venteProvider.ajouterProduit(produit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produit.nom} ajouté au panier'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  /// Afficher une erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caisse'),
        backgroundColor: AppColors.vente,
        foregroundColor: AppColors.textLight,
        actions: [
          // Bouton ventes en attente
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

          // Bouton historique
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

          const SizedBox(width: AppStyles.paddingS),
        ],
      ),
      body: Row(
        children: [
          // Partie gauche : Sélection des produits (60%)
          Expanded(
            flex: 6,
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Barre de recherche
                  SearchBarWidget(
                    controller: _searchController,
                    onSearch: _rechercherProduits,
                    onScan: (codeBarre) async {
                      // Scanner un code-barres
                      try {
                        final venteProvider = context.read<VenteProvider>();
                        final produit = await venteProvider
                            .rechercherProduitParCodeBarre(codeBarre);

                        if (produit != null) {
                          await _ajouterAuPanier(produit);
                        } else {
                          _showError('Produit non trouvé');
                        }
                      } catch (e) {
                        _showError(e.toString());
                      }
                    },
                  ),

                  // Chips de catégories
                  CategorieChips(
                    categorieSelectionnee: _categorieSelectionnee,
                    onCategorieSelected: _filtrerParCategorie,
                  ),

                  // Grille de produits
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ProduitGrid(
                              produits: _produits,
                              onProduitTap: _ajouterAuPanier,
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Séparateur vertical
          Container(width: 1, color: AppColors.border),

          // Partie droite : Panier (40%)
          Expanded(flex: 4, child: PanierWidget()),
        ],
      ),
    );
  }
}
