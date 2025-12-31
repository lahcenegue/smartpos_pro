import '../core/utils/helpers.dart';

/// Modèle pour une ligne de vente (produit dans le panier)
class LigneVente {
  final int? id;
  final int? venteId;
  final int produitId;
  final int? varianteId;
  final String nomProduit;
  final String? codeBarre;
  final double quantite;
  final double prixUnitaireHT;
  final double prixUnitaireTTC;
  final double tauxTVA;
  final double remiseLigne;
  final double remisePourcentage;
  final int ordre;

  LigneVente({
    this.id,
    this.venteId,
    required this.produitId,
    this.varianteId,
    required this.nomProduit,
    this.codeBarre,
    required this.quantite,
    required this.prixUnitaireHT,
    required this.prixUnitaireTTC,
    required this.tauxTVA,
    this.remiseLigne = 0,
    this.remisePourcentage = 0,
    this.ordre = 0,
  });

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vente_id': venteId,
      'produit_id': produitId,
      'variante_id': varianteId,
      'nom_produit': nomProduit,
      'code_barre': codeBarre,
      'quantite': quantite,
      'prix_unitaire_ht': prixUnitaireHT,
      'prix_unitaire_ttc': prixUnitaireTTC,
      'tva_taux': tauxTVA,
      'remise_ligne': remiseLigne,
      'remise_pourcentage': remisePourcentage,
      'total_ht': totalHT,
      'total_tva': totalTVA,
      'total_ttc': totalTTC,
      'ordre': ordre,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory LigneVente.fromMap(Map<String, dynamic> map) {
    return LigneVente(
      id: map['id'],
      venteId: map['vente_id'],
      produitId: map['produit_id'],
      varianteId: map['variante_id'],
      nomProduit: map['nom_produit'],
      codeBarre: map['code_barre'],
      quantite: map['quantite']?.toDouble() ?? 1,
      prixUnitaireHT: map['prix_unitaire_ht']?.toDouble() ?? 0,
      prixUnitaireTTC: map['prix_unitaire_ttc']?.toDouble() ?? 0,
      tauxTVA: map['tva_taux']?.toDouble() ?? 0,
      remiseLigne: map['remise_ligne']?.toDouble() ?? 0,
      remisePourcentage: map['remise_pourcentage']?.toDouble() ?? 0,
      ordre: map['ordre'] ?? 0,
    );
  }

  /// Getters calculés

  /// Total HT de la ligne (avant remise)
  double get sousTotal => prixUnitaireHT * quantite;

  /// Montant de la remise
  double get montantRemise {
    if (remiseLigne > 0) {
      return remiseLigne;
    } else if (remisePourcentage > 0) {
      return sousTotal * (remisePourcentage / 100);
    }
    return 0;
  }

  /// Total HT après remise
  double get totalHT => Helpers.arrondir(sousTotal - montantRemise);

  /// Montant de la TVA
  double get totalTVA =>
      Helpers.arrondir(Helpers.calculerTVA(totalHT, tauxTVA));

  /// Total TTC
  double get totalTTC => Helpers.arrondir(totalHT + totalTVA);

  /// Prix unitaire après remise
  double get prixUnitaireApresRemise {
    if (quantite == 0) return 0;
    return totalTTC / quantite;
  }

  /// Vérifier si la ligne a une remise
  bool get aRemise => remiseLigne > 0 || remisePourcentage > 0;

  /// CopyWith pour immutabilité
  LigneVente copyWith({
    int? id,
    int? venteId,
    int? produitId,
    int? varianteId,
    String? nomProduit,
    String? codeBarre,
    double? quantite,
    double? prixUnitaireHT,
    double? prixUnitaireTTC,
    double? tauxTVA,
    double? remiseLigne,
    double? remisePourcentage,
    int? ordre,
  }) {
    return LigneVente(
      id: id ?? this.id,
      venteId: venteId ?? this.venteId,
      produitId: produitId ?? this.produitId,
      varianteId: varianteId ?? this.varianteId,
      nomProduit: nomProduit ?? this.nomProduit,
      codeBarre: codeBarre ?? this.codeBarre,
      quantite: quantite ?? this.quantite,
      prixUnitaireHT: prixUnitaireHT ?? this.prixUnitaireHT,
      prixUnitaireTTC: prixUnitaireTTC ?? this.prixUnitaireTTC,
      tauxTVA: tauxTVA ?? this.tauxTVA,
      remiseLigne: remiseLigne ?? this.remiseLigne,
      remisePourcentage: remisePourcentage ?? this.remisePourcentage,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  String toString() {
    return 'LigneVente(produit: $nomProduit, qté: $quantite, total: $totalTTC)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LigneVente &&
        other.produitId == produitId &&
        other.varianteId == varianteId;
  }

  @override
  int get hashCode => Object.hash(produitId, varianteId);
}
