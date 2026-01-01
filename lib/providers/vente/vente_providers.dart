import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/produit.dart';
import '../../models/vente.dart';
import '../../models/ligne_vente.dart';
import '../../repositories/vente_repository.dart';
import '../../repositories/produit_repository.dart';
import '../../core/utils/helpers.dart';

part 'vente_providers.g.dart';

// ==================== REPOSITORIES ====================

@riverpod
VenteRepository venteRepository(Ref ref) {
  return VenteRepository();
}

@riverpod
ProduitRepository produitRepository(Ref ref) {
  return ProduitRepository();
}

// ==================== ÉTAT DU PANIER ====================

@riverpod
class Panier extends _$Panier {
  @override
  List<LigneVente> build() => [];

  void ajouterProduit(Produit produit, {double quantite = 1}) {
    final quantiteDejaDansPanier = state
        .where((l) => l.produitId == produit.id)
        .fold<double>(0, (sum, ligne) => sum + ligne.quantite);

    if (quantiteDejaDansPanier + quantite > produit.stock) {
      throw Exception(
        'Stock insuffisant ! Disponible: ${produit.stock}, Dans le panier: ${quantiteDejaDansPanier.toInt()}',
      );
    }

    final index = state.indexWhere((l) => l.produitId == produit.id);

    if (index != -1) {
      final newState = List<LigneVente>.from(state);
      newState[index] = newState[index].copyWith(
        quantite: newState[index].quantite + quantite,
      );
      state = newState;
    } else {
      state = [
        ...state,
        LigneVente(
          produitId: produit.id!,
          nomProduit: produit.nom,
          codeBarre: produit.codeBarre,
          quantite: quantite,
          prixUnitaireHT: produit.prixHT,
          prixUnitaireTTC: produit.prixVente,
          tauxTVA: produit.tauxTva,
          ordre: state.length,
        ),
      ];
    }
  }

  void modifierQuantite(int index, double nouvelleQuantite) {
    if (nouvelleQuantite <= 0) {
      supprimerLigne(index);
      return;
    }

    final newState = List<LigneVente>.from(state);
    newState[index] = newState[index].copyWith(quantite: nouvelleQuantite);
    state = newState;
  }

  void supprimerLigne(int index) {
    state = [...state.sublist(0, index), ...state.sublist(index + 1)];
  }

  void vider() {
    state = [];
  }
}

// ==================== TOTAUX ====================

@riverpod
double totalHT(Ref ref) {
  final panier = ref.watch(panierProvider);
  return panier.fold(0, (sum, ligne) => sum + ligne.totalHT);
}

@riverpod
double totalTVA(Ref ref) {
  final panier = ref.watch(panierProvider);
  return panier.fold(0, (sum, ligne) => sum + ligne.totalTVA);
}

@riverpod
double totalTTC(Ref ref) {
  final panier = ref.watch(panierProvider);
  final remise = ref.watch(remiseGlobaleProvider);
  final total = panier.fold(0.0, (sum, ligne) => sum + ligne.totalTTC);
  return total - remise;
}

@riverpod
int nombreArticles(Ref ref) {
  final panier = ref.watch(panierProvider);
  return panier.fold(0, (sum, ligne) => sum + ligne.quantite.toInt());
}

// ==================== REMISE ====================

@riverpod
class RemiseGlobale extends _$RemiseGlobale {
  @override
  double build() => 0;

  void appliquer(double montant) {
    state = montant;
  }

  void annuler() {
    state = 0;
  }
}

// ==================== FINALISATION ====================

@riverpod
class VenteFinalisation extends _$VenteFinalisation {
  @override
  FutureOr<Vente?> build() => null;

  Future<Vente> finaliser({
    required String modePaiement,
    required double montantPaye,
    int? utilisateurId,
  }) async {
    final panier = ref.read(panierProvider);
    final remise = ref.read(remiseGlobaleProvider);

    if (panier.isEmpty) {
      throw Exception('Le panier est vide');
    }

    for (var ligne in panier) {
      final produit = await ref
          .read(produitRepositoryProvider)
          .getProduitById(ligne.produitId);

      if (produit == null || produit.stock < ligne.quantite) {
        throw Exception('Stock insuffisant pour ${ligne.nomProduit}');
      }
    }

    final vente = Vente.fromLignes(
      lignes: panier,
      utilisateurId: utilisateurId ?? 1,
      modePaiement: modePaiement,
      montantPaye: montantPaye,
      numeroFacture: Helpers.generateNumeroTicket(),
      remiseGlobale: remise,
    );

    final venteId = await ref.read(venteRepositoryProvider).creerVente(vente);

    for (var ligne in panier) {
      final produit = await ref
          .read(produitRepositoryProvider)
          .getProduitById(ligne.produitId);

      if (produit != null) {
        await ref
            .read(produitRepositoryProvider)
            .mettreAJourStock(
              produit.id!,
              (produit.stock - ligne.quantite.toInt()).clamp(0, 999999),
            );
      }
    }

    ref.read(panierProvider.notifier).vider();
    ref.read(remiseGlobaleProvider.notifier).annuler();
    ref.invalidate(statsJourProvider);

    return vente.copyWith(id: venteId);
  }
}

// ==================== STATS ====================

@riverpod
Future<Map<String, dynamic>> statsJour(Ref ref) async {
  final now = DateTime.now();
  final debut = now.copyWith(hour: 0, minute: 0, second: 0);
  final fin = now.copyWith(hour: 23, minute: 59, second: 59);

  final ventes = await ref
      .read(venteRepositoryProvider)
      .getVentesParPeriode(debut, fin);

  final ventesTerminees = ventes.where((v) => v.statut == 'terminee').toList();
  final ca = ventesTerminees.fold<double>(0, (sum, v) => sum + v.montantTTC);
  final nbVentes = ventesTerminees.length;

  return {
    'nombreVentes': nbVentes,
    'ca': ca,
    'panierMoyen': nbVentes > 0 ? ca / nbVentes : 0.0,
  };
}

// ==================== VENTES EN ATTENTE ====================

@riverpod
Future<List<Vente>> ventesEnAttente(Ref ref) async {
  return await ref.read(venteRepositoryProvider).getVentesEnAttente();
}

@riverpod
class VenteAttente extends _$VenteAttente {
  @override
  Future<void> build() async {}

  Future<Vente> mettreEnAttente({int? utilisateurId, String? notes}) async {
    final panier = ref.read(panierProvider);
    final remise = ref.read(remiseGlobaleProvider);

    if (panier.isEmpty) {
      throw Exception('Le panier est vide');
    }

    final vente = Vente.fromLignes(
      lignes: panier,
      utilisateurId: utilisateurId ?? 1,
      modePaiement: 'especes', // ← CHANGER de '' vers 'especes' (par défaut)
      montantPaye: 0,
      numeroFacture: Helpers.generateNumeroTicket(),
      remiseGlobale: remise,
    ).copyWith(statut: 'en_attente', notes: notes);

    final venteId = await ref.read(venteRepositoryProvider).creerVente(vente);

    ref.read(panierProvider.notifier).vider();
    ref.read(remiseGlobaleProvider.notifier).annuler();
    ref.invalidate(ventesEnAttenteProvider);

    return vente.copyWith(id: venteId);
  }

  Future<void> charger(Vente vente) async {
    if (vente.statut != 'en_attente') {
      throw Exception('Cette vente n\'est pas en attente');
    }

    ref.read(panierProvider.notifier).vider();
    ref.read(remiseGlobaleProvider.notifier).annuler();

    for (var ligne in vente.lignes) {
      final produit = await ref
          .read(produitRepositoryProvider)
          .getProduitById(ligne.produitId);

      if (produit == null) {
        throw Exception('Produit ${ligne.nomProduit} introuvable');
      }

      if (produit.stock < ligne.quantite) {
        throw Exception(
          'Stock insuffisant pour ${produit.nom}. Disponible: ${produit.stock}',
        );
      }

      ref
          .read(panierProvider.notifier)
          .ajouterProduit(produit, quantite: ligne.quantite);
    }

    if (vente.remisePourcentage > 0) {
      final totalHT = ref.read(totalHTProvider);
      final remise = totalHT * (vente.remisePourcentage / 100);
      ref.read(remiseGlobaleProvider.notifier).appliquer(remise);
    } else if (vente.montantRemise > 0) {
      ref.read(remiseGlobaleProvider.notifier).appliquer(vente.montantRemise);
    }

    await ref.read(venteRepositoryProvider).supprimerVente(vente.id!);
    ref.invalidate(ventesEnAttenteProvider);
  }

  Future<void> supprimer(int venteId) async {
    await ref.read(venteRepositoryProvider).supprimerVente(venteId);
    ref.invalidate(ventesEnAttenteProvider);
  }
}

// ==================== HISTORIQUE ====================

@riverpod
class HistoriqueVentes extends _$HistoriqueVentes {
  @override
  Future<List<Vente>> build({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
  }) async {
    List<Vente> ventes;

    if (dateDebut != null && dateFin != null) {
      ventes = await ref
          .read(venteRepositoryProvider)
          .getVentesParPeriode(dateDebut, dateFin);
    } else {
      ventes = await ref
          .read(venteRepositoryProvider)
          .getToutesVentes(limit: 100);
    }

    if (statut != null && statut != 'tous') {
      ventes = ventes.where((v) => v.statut == statut).toList();
    }

    return ventes;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ==================== ANNULATION ====================

@riverpod
class AnnulationVente extends _$AnnulationVente {
  @override
  FutureOr<void> build() => null;

  Future<void> annuler({
    required int venteId,
    required String motif,
    int? utilisateurId,
  }) async {
    final vente = await ref.read(venteRepositoryProvider).getVenteById(venteId);

    if (vente == null) {
      throw Exception('Vente introuvable');
    }

    if (vente.statut == 'annulee') {
      throw Exception('Cette vente est déjà annulée');
    }

    if (vente.statut != 'terminee') {
      throw Exception('Seules les ventes terminées peuvent être annulées');
    }

    // ← CORRECTION : Arguments positionnels dans l'ordre (id, motif, utilisateurId)
    await ref
        .read(venteRepositoryProvider)
        .annulerVente(venteId, motif, utilisateurId ?? 1);

    ref.invalidate(historiqueVentesProvider);
    ref.invalidate(statsJourProvider);
  }
}

@riverpod
Future<Vente?> detailVente(Ref ref, int venteId) async {
  return await ref.read(venteRepositoryProvider).getVenteById(venteId);
}
