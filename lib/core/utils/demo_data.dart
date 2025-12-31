import '../services/database_service.dart';

/// Classe pour insérer des données de démonstration
class DemoData {
  static final DatabaseService _db = DatabaseService.instance;

  /// Insérer des produits de démonstration
  static Future<void> insererProduitsDeMo() async {
    final db = await _db.database;

    // Vérifier si des produits existent déjà
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM produits');
    final produitCount = count.first['count'] as int;

    if (produitCount > 0) {
      print('Des produits existent déjà en base');
      return;
    }

    print('Insertion de produits de démonstration...');

    // Liste de produits de démo
    final produits = [
      // Alimentation (catégorie 1)
      {
        'code_barre': '3245678901234',
        'nom': 'Pain Complet',
        'description': 'Pain complet tranché 500g',
        'categorie_id': 1,
        'prix_achat': 80.0,
        'prix_vente': 150.0,
        'tva_taux': 9.0,
        'stock': 25,
        'stock_minimum': 5,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678901235',
        'nom': 'Lait Entier',
        'description': 'Lait entier 1L',
        'categorie_id': 1,
        'prix_achat': 60.0,
        'prix_vente': 120.0,
        'tva_taux': 9.0,
        'stock': 50,
        'stock_minimum': 10,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678901236',
        'nom': 'Fromage Emmental',
        'description': 'Fromage Emmental 200g',
        'categorie_id': 1,
        'prix_achat': 200.0,
        'prix_vente': 350.0,
        'tva_taux': 9.0,
        'stock': 15,
        'stock_minimum': 5,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Boissons (catégorie 2)
      {
        'code_barre': '3245678902234',
        'nom': 'Coca-Cola',
        'description': 'Coca-Cola 1.5L',
        'categorie_id': 2,
        'prix_achat': 90.0,
        'prix_vente': 180.0,
        'tva_taux': 19.0,
        'stock': 40,
        'stock_minimum': 10,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678902235',
        'nom': 'Eau Minérale',
        'description': 'Eau minérale 1.5L',
        'categorie_id': 2,
        'prix_achat': 30.0,
        'prix_vente': 60.0,
        'tva_taux': 9.0,
        'stock': 100,
        'stock_minimum': 20,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678902236',
        'nom': 'Jus d\'Orange',
        'description': 'Jus d\'orange 100% pur 1L',
        'categorie_id': 2,
        'prix_achat': 120.0,
        'prix_vente': 250.0,
        'tva_taux': 9.0,
        'stock': 30,
        'stock_minimum': 8,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Hygiène & Beauté (catégorie 3)
      {
        'code_barre': '3245678903234',
        'nom': 'Savon Liquide',
        'description': 'Savon liquide antibactérien 500ml',
        'categorie_id': 3,
        'prix_achat': 150.0,
        'prix_vente': 300.0,
        'tva_taux': 19.0,
        'stock': 20,
        'stock_minimum': 5,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678903235',
        'nom': 'Shampoing',
        'description': 'Shampoing tous types de cheveux 400ml',
        'categorie_id': 3,
        'prix_achat': 250.0,
        'prix_vente': 500.0,
        'tva_taux': 19.0,
        'stock': 18,
        'stock_minimum': 5,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Entretien (catégorie 4)
      {
        'code_barre': '3245678904234',
        'nom': 'Liquide Vaisselle',
        'description': 'Liquide vaisselle citron 750ml',
        'categorie_id': 4,
        'prix_achat': 100.0,
        'prix_vente': 200.0,
        'tva_taux': 19.0,
        'stock': 25,
        'stock_minimum': 8,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
      {
        'code_barre': '3245678904235',
        'nom': 'Javel',
        'description': 'Eau de javel concentrée 1L',
        'categorie_id': 4,
        'prix_achat': 80.0,
        'prix_vente': 150.0,
        'tva_taux': 19.0,
        'stock': 30,
        'stock_minimum': 10,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Produit en promotion
      {
        'code_barre': '3245678905234',
        'nom': 'Café Moulu',
        'description': 'Café moulu arabica 250g',
        'categorie_id': 1,
        'prix_achat': 300.0,
        'prix_vente': 600.0,
        'prix_promotion': 450.0,
        'tva_taux': 9.0,
        'stock': 15,
        'stock_minimum': 5,
        'actif': 1,
        'en_promotion': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Produit en stock bas
      {
        'code_barre': '3245678905235',
        'nom': 'Huile d\'Olive',
        'description': 'Huile d\'olive extra vierge 500ml',
        'categorie_id': 1,
        'prix_achat': 400.0,
        'prix_vente': 750.0,
        'tva_taux': 9.0,
        'stock': 3,
        'stock_minimum': 5,
        'actif': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },

      // Produit en rupture
      {
        'code_barre': '3245678905236',
        'nom': 'Sucre Blanc',
        'description': 'Sucre blanc cristallisé 1kg',
        'categorie_id': 1,
        'prix_achat': 80.0,
        'prix_vente': 150.0,
        'tva_taux': 9.0,
        'stock': 0,
        'stock_minimum': 10,
        'actif': 1,
        'en_rupture': 1,
        'date_creation': DateTime.now().toIso8601String(),
      },
    ];

    // Insérer tous les produits
    for (var produit in produits) {
      await db.insert('produits', produit);
    }

    print('✅ ${produits.length} produits de démonstration insérés !');
  }

  /// Supprimer toutes les données de démo
  static Future<void> supprimerDonneesDeMo() async {
    final db = await _db.database;

    // Supprimer tous les produits
    await db.delete('produits');

    print('✅ Données de démonstration supprimées !');
  }
}
