import '../core/utils/helpers.dart';
import '../core/constants/app_constants.dart';

/// Modèle pour les produits
class Produit {
  final int? id;
  final String? codeBarre;
  final String? reference;
  final String nom;
  final String? description;
  final int? categorieId;
  final double prixAchat;
  final double prixVente;
  final double? prixPromotion;
  final double tauxTva;
  final int stock;
  final int stockMinimum;
  final int? stockMaximum;
  final String unite;
  final String? marque;
  final String? imagePath;
  final bool aVariantes;
  final double? poids;
  final bool actif;
  final bool enPromotion;
  final bool enRupture;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final int? utilisateurCreationId;

  Produit({
    this.id,
    this.codeBarre,
    this.reference,
    required this.nom,
    this.description,
    this.categorieId,
    this.prixAchat = 0,
    required this.prixVente,
    this.prixPromotion,
    this.tauxTva = AppConstants.tauxTVANormal,
    this.stock = 0,
    this.stockMinimum = AppConstants.stockMinimumDefaut,
    this.stockMaximum,
    this.unite = 'unité',
    this.marque,
    this.imagePath,
    this.aVariantes = false,
    this.poids,
    this.actif = true,
    this.enPromotion = false,
    this.enRupture = false,
    DateTime? dateCreation,
    this.dateModification,
    this.utilisateurCreationId,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code_barre': codeBarre,
      'reference': reference,
      'nom': nom,
      'description': description,
      'categorie_id': categorieId,
      'prix_achat': prixAchat,
      'prix_vente': prixVente,
      'prix_promotion': prixPromotion,
      'tva_taux': tauxTva,
      'stock': stock,
      'stock_minimum': stockMinimum,
      'stock_maximum': stockMaximum,
      'unite': unite,
      'marque': marque,
      'image_path': imagePath,
      'a_variantes': aVariantes ? 1 : 0,
      'poids': poids,
      'actif': actif ? 1 : 0,
      'en_promotion': enPromotion ? 1 : 0,
      'en_rupture': enRupture ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'utilisateur_creation_id': utilisateurCreationId,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'],
      codeBarre: map['code_barre'],
      reference: map['reference'],
      nom: map['nom'],
      description: map['description'],
      categorieId: map['categorie_id'],
      prixAchat: map['prix_achat']?.toDouble() ?? 0,
      prixVente: map['prix_vente']?.toDouble() ?? 0,
      prixPromotion: map['prix_promotion']?.toDouble(),
      tauxTva: map['tva_taux']?.toDouble() ?? AppConstants.tauxTVANormal,
      stock: map['stock'] ?? 0,
      stockMinimum: map['stock_minimum'] ?? AppConstants.stockMinimumDefaut,
      stockMaximum: map['stock_maximum'],
      unite: map['unite'] ?? 'unité',
      marque: map['marque'],
      imagePath: map['image_path'],
      aVariantes: map['a_variantes'] == 1,
      poids: map['poids']?.toDouble(),
      actif: map['actif'] == 1,
      enPromotion: map['en_promotion'] == 1,
      enRupture: map['en_rupture'] == 1,
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification:
          map['date_modification'] != null
              ? DateTime.parse(map['date_modification'])
              : null,
      utilisateurCreationId: map['utilisateur_creation_id'],
    );
  }

  /// Getters calculés

  /// Prix HT calculé à partir du TTC
  double get prixHT => Helpers.calculerHT(prixVente, tauxTva);

  /// Montant de la TVA
  double get montantTVA => Helpers.calculerTVA(prixHT, tauxTva);

  /// Marge en montant
  double get marge => prixVente - prixAchat;

  /// Marge en pourcentage
  double get margePourcentage =>
      Helpers.calculerMargePourcentage(prixAchat, prixVente);

  /// Prix effectif (avec promotion si applicable)
  double get prixEffectif =>
      enPromotion && prixPromotion != null ? prixPromotion! : prixVente;

  /// Vérifier si le stock est bas
  bool get stockBas => stock <= stockMinimum && stock > 0;

  /// Vérifier si le produit est disponible
  bool get disponible => actif && !enRupture && stock > 0;

  /// CopyWith pour immutabilité
  Produit copyWith({
    int? id,
    String? codeBarre,
    String? reference,
    String? nom,
    String? description,
    int? categorieId,
    double? prixAchat,
    double? prixVente,
    double? prixPromotion,
    double? tauxTva,
    int? stock,
    int? stockMinimum,
    int? stockMaximum,
    String? unite,
    String? marque,
    String? imagePath,
    bool? aVariantes,
    double? poids,
    bool? actif,
    bool? enPromotion,
    bool? enRupture,
    DateTime? dateCreation,
    DateTime? dateModification,
    int? utilisateurCreationId,
  }) {
    return Produit(
      id: id ?? this.id,
      codeBarre: codeBarre ?? this.codeBarre,
      reference: reference ?? this.reference,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorieId: categorieId ?? this.categorieId,
      prixAchat: prixAchat ?? this.prixAchat,
      prixVente: prixVente ?? this.prixVente,
      prixPromotion: prixPromotion ?? this.prixPromotion,
      tauxTva: tauxTva ?? this.tauxTva,
      stock: stock ?? this.stock,
      stockMinimum: stockMinimum ?? this.stockMinimum,
      stockMaximum: stockMaximum ?? this.stockMaximum,
      unite: unite ?? this.unite,
      marque: marque ?? this.marque,
      imagePath: imagePath ?? this.imagePath,
      aVariantes: aVariantes ?? this.aVariantes,
      poids: poids ?? this.poids,
      actif: actif ?? this.actif,
      enPromotion: enPromotion ?? this.enPromotion,
      enRupture: enRupture ?? this.enRupture,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      utilisateurCreationId:
          utilisateurCreationId ?? this.utilisateurCreationId,
    );
  }

  @override
  String toString() {
    return 'Produit(id: $id, nom: $nom, prix: $prixVente, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Produit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
