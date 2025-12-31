import '../core/services/database_service.dart';
import '../core/errors/exceptions.dart';
import '../models/produit.dart';
import '../models/categorie.dart';

/// Repository pour la gestion des produits
class ProduitRepository {
  final DatabaseService _db = DatabaseService.instance;

  /// CREATE - Créer un nouveau produit
  Future<int> creerProduit(Produit produit) async {
    try {
      final db = await _db.database;
      return await db.insert('produits', produit.toMap());
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la création du produit: $e');
    }
  }

  /// READ - Récupérer tous les produits actifs
  Future<List<Produit>> getTousProduits() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'actif = ?',
        whereArgs: [1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits: $e',
      );
    }
  }

  /// READ - Récupérer un produit par ID
  Future<Produit?> getProduitById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Produit.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération du produit: $e',
      );
    }
  }

  /// READ - Récupérer un produit par code-barres
  Future<Produit?> getProduitByCodeBarre(String codeBarre) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'code_barre = ? AND actif = ?',
        whereArgs: [codeBarre, 1],
      );

      if (maps.isEmpty) return null;
      return Produit.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération du produit: $e',
      );
    }
  }

  /// READ - Rechercher des produits
  Future<List<Produit>> rechercherProduits(String query) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where:
            'actif = ? AND (nom LIKE ? OR code_barre LIKE ? OR reference LIKE ? OR description LIKE ?)',
        whereArgs: [1, '%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la recherche de produits: $e');
    }
  }

  /// READ - Récupérer les produits par catégorie
  Future<List<Produit>> getProduitsByCategorie(int categorieId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'categorie_id = ? AND actif = ?',
        whereArgs: [categorieId, 1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits: $e',
      );
    }
  }

  /// READ - Récupérer les produits en stock bas
  Future<List<Produit>> getProduitsStockBas() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM produits
        WHERE actif = 1 AND stock <= stock_minimum AND stock > 0
        ORDER BY (stock_minimum - stock) DESC
      ''');
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits en stock bas: $e',
      );
    }
  }

  /// READ - Récupérer les produits en rupture
  Future<List<Produit>> getProduitsEnRupture() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'actif = 1 AND (en_rupture = 1 OR stock <= 0)',
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits en rupture: $e',
      );
    }
  }

  /// READ - Récupérer les produits en promotion
  Future<List<Produit>> getProduitsEnPromotion() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: 'actif = 1 AND en_promotion = 1',
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits en promotion: $e',
      );
    }
  }

  /// READ - Récupérer les produits avec pagination
  Future<List<Produit>> getProduitsPagination({
    required int limit,
    required int offset,
    String? recherche,
    int? categorieId,
  }) async {
    try {
      final db = await _db.database;

      String whereClause = 'actif = ?';
      List<dynamic> whereArgs = [1];

      if (recherche != null && recherche.isNotEmpty) {
        whereClause += ' AND (nom LIKE ? OR code_barre LIKE ?)';
        whereArgs.addAll(['%$recherche%', '%$recherche%']);
      }

      if (categorieId != null) {
        whereClause += ' AND categorie_id = ?';
        whereArgs.add(categorieId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'produits',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'nom ASC',
        limit: limit,
        offset: offset,
      );

      return List.generate(maps.length, (i) => Produit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des produits: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour un produit
  Future<int> mettreAJourProduit(Produit produit) async {
    try {
      final db = await _db.database;
      return await db.update(
        'produits',
        produit.toMap(),
        where: 'id = ?',
        whereArgs: [produit.id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour du produit: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour uniquement le stock
  Future<int> mettreAJourStock(int produitId, int nouvelleQuantite) async {
    try {
      final db = await _db.database;
      return await db.update(
        'produits',
        {
          'stock': nouvelleQuantite,
          'en_rupture': nouvelleQuantite <= 0 ? 1 : 0,
          'date_modification': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [produitId],
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la mise à jour du stock: $e');
    }
  }

  /// UPDATE - Ajuster le stock (ajouter ou retirer)
  Future<int> ajusterStock(int produitId, int ajustement) async {
    try {
      // Récupérer le stock actuel
      final produit = await getProduitById(produitId);
      if (produit == null) {
        throw ProduitIntrouvableException('$produitId');
      }

      int nouveauStock = produit.stock + ajustement;
      if (nouveauStock < 0) nouveauStock = 0;

      return await mettreAJourStock(produitId, nouveauStock);
    } catch (e) {
      throw AppDatabaseException('Erreur lors de l\'ajustement du stock: $e');
    }
  }

  /// DELETE - Supprimer un produit (soft delete)
  Future<int> supprimerProduit(int id) async {
    try {
      final db = await _db.database;
      return await db.update(
        'produits',
        {'actif': 0, 'date_modification': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression du produit: $e',
      );
    }
  }

  /// DELETE - Supprimer définitivement un produit
  Future<int> supprimerProduitDefinitivement(int id) async {
    try {
      final db = await _db.database;
      return await db.delete('produits', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression définitive: $e',
      );
    }
  }

  /// STATS - Obtenir les statistiques des produits
  Future<Map<String, dynamic>> getStatistiquesProduits() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT
          COUNT(*) as total_produits,
          SUM(stock) as quantite_totale,
          SUM(stock * prix_achat) as valeur_achat,
          SUM(stock * prix_vente) as valeur_vente,
          COUNT(CASE WHEN stock <= 0 THEN 1 END) as produits_rupture,
          COUNT(CASE WHEN stock <= stock_minimum AND stock > 0 THEN 1 END) as produits_stock_bas
        FROM produits
        WHERE actif = 1
      ''');

      return result.first;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// VERIFICATION - Vérifier si un code-barres existe déjà
  Future<bool> codeBarreExiste(
    String codeBarre, {
    int? excludeProduitId,
  }) async {
    try {
      final db = await _db.database;

      String whereClause = 'code_barre = ?';
      List<dynamic> whereArgs = [codeBarre];

      if (excludeProduitId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeProduitId);
      }

      final result = await db.query(
        'produits',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la vérification du code-barres: $e',
      );
    }
  }

  /// CATEGORIES - Récupérer toutes les catégories
  Future<List<Categorie>> getToutesCategories() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: 'actif = ?',
        whereArgs: [1],
        orderBy: 'ordre ASC, nom ASC',
      );
      return List.generate(maps.length, (i) => Categorie.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des catégories: $e',
      );
    }
  }

  /// CATEGORIES - Créer une catégorie
  Future<int> creerCategorie(Categorie categorie) async {
    try {
      final db = await _db.database;
      return await db.insert('categories', categorie.toMap());
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la création de la catégorie: $e',
      );
    }
  }

  /// CATEGORIES - Mettre à jour une catégorie
  Future<int> mettreAJourCategorie(Categorie categorie) async {
    try {
      final db = await _db.database;
      return await db.update(
        'categories',
        categorie.toMap(),
        where: 'id = ?',
        whereArgs: [categorie.id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour de la catégorie: $e',
      );
    }
  }

  /// CATEGORIES - Supprimer une catégorie
  Future<int> supprimerCategorie(int id) async {
    try {
      final db = await _db.database;
      return await db.update(
        'categories',
        {'actif': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression de la catégorie: $e',
      );
    }
  }

  /// CATEGORIES - Compter les produits par catégorie
  Future<Map<int, int>> compterProduitsParCategorie() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT categorie_id, COUNT(*) as count
        FROM produits
        WHERE actif = 1 AND categorie_id IS NOT NULL
        GROUP BY categorie_id
      ''');

      Map<int, int> stats = {};
      for (var row in result) {
        stats[row['categorie_id'] as int] = row['count'] as int;
      }

      return stats;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du comptage des produits: $e');
    }
  }
}
