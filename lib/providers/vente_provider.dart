import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../models/client.dart';
import '../models/vente.dart';
import '../models/ligne_vente.dart';
import '../repositories/vente_repository.dart';
import '../repositories/produit_repository.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/helpers.dart';
import '../core/constants/app_constants.dart';

/// Provider pour la gestion des ventes et du panier
class VenteProvider with ChangeNotifier {
  final VenteRepository _venteRepo = VenteRepository();
  final ProduitRepository _produitRepo = ProduitRepository();

  VoidCallback? onVenteFinalisee;

  bool _genererFacture = false;

  // État du panier
  List<LigneVente> _panier = [];
  Client? _clientSelectionne;
  double _remiseGlobale = 0;
  int _pointsAUtiliser = 0;

  // Getters
  bool get genererFacture => _genererFacture;

  List<LigneVente> get panier => List.unmodifiable(_panier);
  Client? get clientSelectionne => _clientSelectionne;
  double get remiseGlobale => _remiseGlobale;
  int get pointsAUtiliser => _pointsAUtiliser;

  bool get panierVide => _panier.isEmpty;
  int get nombreArticles => _panier.length;
  int get quantiteTotale =>
      _panier.fold(0, (sum, ligne) => sum + ligne.quantite.toInt());

  /// Calculs des totaux
  double get sousTotal {
    return _panier.fold(0.0, (sum, ligne) => sum + ligne.totalHT);
  }

  double get totalTVA {
    return _panier.fold(0.0, (sum, ligne) => sum + ligne.totalTVA);
  }

  double get totalAvantRemise {
    return _panier.fold(0.0, (sum, ligne) => sum + ligne.totalTTC);
  }

  double get montantRemiseGlobale {
    return _remiseGlobale;
  }

  double get valeurPointsUtilises {
    return Helpers.calculerValeurPoints(_pointsAUtiliser);
  }

  double get totalTTC {
    double total =
        totalAvantRemise - montantRemiseGlobale - valeurPointsUtilises;
    return total < 0 ? 0 : Helpers.arrondir(total);
  }

  // Méthode pour activer/désactiver la facture
  void toggleFacture(bool value) {
    _genererFacture = value;
    notifyListeners();
  }

  /// Ajouter un produit au panier
  /// Ajouter un produit au panier
  Future<void> ajouterProduit(Produit produit, {double quantite = 1}) async {
    // ← AJOUTER : Vérifier le stock disponible
    final quantiteDejaDansPanier = _panier
        .where((l) => l.produitId == produit.id)
        .fold<double>(0, (sum, ligne) => sum + ligne.quantite);

    final quantiteTotale = quantiteDejaDansPanier + quantite;

    if (quantiteTotale > produit.stock) {
      throw ValidationException(
        'Stock insuffisant ! Disponible: ${produit.stock}, Dans le panier: ${quantiteDejaDansPanier.toInt()}',
      );
    }

    // Chercher si le produit existe déjà dans le panier
    final index = _panier.indexWhere((l) => l.produitId == produit.id);

    if (index != -1) {
      // Produit déjà dans le panier, augmenter la quantité
      _panier[index] = _panier[index].copyWith(
        quantite: _panier[index].quantite + quantite,
      );
    } else {
      // Nouveau produit
      _panier.add(
        LigneVente(
          produitId: produit.id!,
          nomProduit: produit.nom,
          codeBarre: produit.codeBarre,
          quantite: quantite,
          prixUnitaireHT: produit.prixHT,
          prixUnitaireTTC: produit.prixVente,
          tauxTVA: produit.tauxTva,
          ordre: _panier.length,
        ),
      );
    }

    notifyListeners();
  }

  /// Modifier la quantité d'une ligne
  void modifierQuantite(int index, double nouvelleQuantite) {
    if (nouvelleQuantite <= 0) {
      supprimerLigne(index);
      return;
    }

    // Récupérer le produit pour vérifier le stock
    // Note: On devrait avoir le stock dans la ligne, mais pour l'instant on fait une validation simple
    // TODO: Ajouter le stock disponible dans LigneVente pour une meilleure validation

    _panier[index] = _panier[index].copyWith(quantite: nouvelleQuantite);
    notifyListeners();
  }

  /// Augmenter la quantité
  void augmenterQuantite(int index) {
    if (index < 0 || index >= _panier.length) return;
    modifierQuantite(index, _panier[index].quantite + 1);
  }

  /// Diminuer la quantité
  void diminuerQuantite(int index) {
    if (index < 0 || index >= _panier.length) return;
    modifierQuantite(index, _panier[index].quantite - 1);
  }

  /// Supprimer une ligne du panier
  void supprimerLigne(int index) {
    if (index < 0 || index >= _panier.length) return;
    _panier.removeAt(index);
    notifyListeners();
  }

  /// Appliquer une remise sur une ligne
  void appliquerRemiseLigne(int index, double remise) {
    if (index < 0 || index >= _panier.length) return;
    _panier[index] = _panier[index].copyWith(remiseLigne: remise);
    notifyListeners();
  }

  /// Appliquer une remise globale
  void appliquerRemiseGlobale(double remise) {
    _remiseGlobale = remise < 0 ? 0 : remise;
    notifyListeners();
  }

  /// Vider le panier
  void viderPanier() {
    _panier.clear();
    _clientSelectionne = null;
    _remiseGlobale = 0;
    _pointsAUtiliser = 0;
    _genererFacture = false;
    notifyListeners();
  }

  /// Sélectionner un client
  void selectionnerClient(Client? client) {
    _clientSelectionne = client;
    _pointsAUtiliser = 0;
    notifyListeners();
  }

  /// Définir les points à utiliser
  void definirPointsAUtiliser(int points) {
    if (_clientSelectionne == null) {
      _pointsAUtiliser = 0;
      notifyListeners();
      return;
    }

    // Vérifier que le client a assez de points
    if (points > _clientSelectionne!.pointsFidelite) {
      _pointsAUtiliser = _clientSelectionne!.pointsFidelite;
    } else if (points < 0) {
      _pointsAUtiliser = 0;
    } else {
      _pointsAUtiliser = points;
    }

    notifyListeners();
  }

  /// Finaliser la vente
  Future<Vente> finaliserVente({
    required String modePaiement,
    required double montantPaye,
    double montantEspeces = 0,
    double montantCarte = 0,
    double montantCheque = 0,
    int? utilisateurId,
    int? sessionCaisseId,
  }) async {
    try {
      if (_panier.isEmpty) {
        throw ValidationException('Le panier est vide');
      }

      if (montantPaye < totalTTC) {
        throw MontantInsuffisantException(
          montantDu: totalTTC,
          montantPaye: montantPaye,
        );
      }

      // Déterminer le type de document selon si facture demandée
      final typeDocument = _genererFacture ? 'facture' : 'ticket';

      // Générer le bon numéro selon le type
      final numeroDocument =
          typeDocument == 'facture'
              ? Helpers.generateNumeroFacture()
              : Helpers.generateNumeroTicket();

      // Créer la vente depuis les lignes AVEC le numéro
      final vente = Vente.fromLignes(
        lignes: List.from(_panier),
        utilisateurId: utilisateurId ?? 1,
        modePaiement: modePaiement,
        montantPaye: montantPaye,
        numeroFacture: numeroDocument, // ← PASSER LE NUMÉRO ICI
        clientId: _clientSelectionne?.id,
        sessionCaisseId: sessionCaisseId,
        remiseGlobale: _remiseGlobale,
        pointsUtilises: _pointsAUtiliser,
      );

      // Ajouter le type de document
      Vente venteComplete = vente.copyWith(typeDocument: typeDocument);

      if (modePaiement == AppConstants.paiementMixte) {
        venteComplete = venteComplete.copyWith(
          montantEspeces: montantEspeces,
          montantCarte: montantCarte,
          montantCheque: montantCheque,
        );
      } else {
        // Mode de paiement unique
        switch (modePaiement) {
          case AppConstants.paiementEspeces:
            venteComplete = venteComplete.copyWith(montantEspeces: totalTTC);
            break;
          case AppConstants.paiementCarte:
            venteComplete = venteComplete.copyWith(montantCarte: totalTTC);
            break;
          case AppConstants.paiementCheque:
            venteComplete = venteComplete.copyWith(montantCheque: totalTTC);
            break;
        }
      }

      // Enregistrer en base
      final venteId = await _venteRepo.creerVente(venteComplete);

      // Récupérer la vente complète avec son ID
      final venteEnregistree = venteComplete.copyWith(id: venteId);

      // Vider le panier
      viderPanier();

      onVenteFinalisee?.call();

      return venteEnregistree;
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre une vente en attente
  Future<void> mettreEnAttente({int? utilisateurId}) async {
    try {
      if (_panier.isEmpty) {
        throw ValidationException('Le panier est vide');
      }

      // Créer la vente en attente
      final vente = Vente.fromLignes(
        lignes: List.from(_panier),
        utilisateurId: utilisateurId ?? 1,
        modePaiement: AppConstants.paiementEspeces, // Par défaut
        montantPaye: 0, // Pas encore payé
        numeroFacture: Helpers.generateNumeroTicket(),
        clientId: _clientSelectionne?.id,
        remiseGlobale: _remiseGlobale,
        pointsUtilises: _pointsAUtiliser,
      );

      // Marquer comme en attente
      final venteEnAttente = vente.copyWith(
        statut: 'en_attente',
        typeDocument: 'ticket',
      );

      // Enregistrer en base
      await _venteRepo.creerVente(venteEnAttente);

      // Vider le panier
      viderPanier();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Charger une vente en attente dans le panier
  Future<void> chargerVenteEnAttente(Vente vente) async {
    try {
      if (vente.statut != AppConstants.venteEnAttente) {
        throw ValidationException('Cette vente n\'est pas en attente');
      }

      // Vider le panier actuel
      _panier.clear();

      // Charger les lignes
      _panier = List.from(vente.lignes);

      // Charger le client si présent
      if (vente.clientId != null) {
        // TODO: Charger le client depuis le repository
        // _clientSelectionne = await _clientRepo.getClientById(vente.clientId!);
      }

      // Charger la remise et les points
      _remiseGlobale = vente.montantRemise;
      _pointsAUtiliser = vente.pointsUtilises;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Rechercher un produit par code-barres
  Future<Produit?> rechercherProduitParCodeBarre(String codeBarre) async {
    try {
      return await _produitRepo.getProduitByCodeBarre(codeBarre);
    } catch (e) {
      rethrow;
    }
  }

  /// Rechercher des produits
  Future<List<Produit>> rechercherProduits(String query) async {
    try {
      return await _produitRepo.rechercherProduits(query);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtenir les produits par catégorie
  Future<List<Produit>> getProduitsByCategorie(int categorieId) async {
    try {
      return await _produitRepo.getProduitsByCategorie(categorieId);
    } catch (e) {
      rethrow;
    }
  }
}
