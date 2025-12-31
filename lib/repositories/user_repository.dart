import '../core/services/database_service.dart';
import '../core/errors/exceptions.dart';
import '../models/utilisateur.dart';

/// Repository pour la gestion des utilisateurs
class UserRepository {
  final DatabaseService _db = DatabaseService.instance;

  /// CREATE - Créer un nouvel utilisateur
  Future<int> creerUtilisateur(Utilisateur utilisateur) async {
    try {
      final db = await _db.database;
      return await db.insert('utilisateurs', utilisateur.toMap());
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la création de l\'utilisateur: $e',
      );
    }
  }

  /// READ - Récupérer tous les utilisateurs
  Future<List<Utilisateur>> getTousUtilisateurs() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Utilisateur.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des utilisateurs: $e',
      );
    }
  }

  /// READ - Récupérer les utilisateurs actifs
  Future<List<Utilisateur>> getUtilisateursActifs() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        where: 'actif = ?',
        whereArgs: [1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Utilisateur.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des utilisateurs actifs: $e',
      );
    }
  }

  /// READ - Récupérer un utilisateur par ID
  Future<Utilisateur?> getUtilisateurById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Utilisateur.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération de l\'utilisateur: $e',
      );
    }
  }

  /// READ - Récupérer un utilisateur par code PIN
  Future<Utilisateur?> getUserByPIN(String pinHash) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        where: 'code_pin = ?',
        whereArgs: [pinHash],
      );

      if (maps.isEmpty) return null;
      return Utilisateur.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération de l\'utilisateur: $e',
      );
    }
  }

  /// READ - Récupérer les utilisateurs par rôle
  Future<List<Utilisateur>> getUtilisateursByRole(String role) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        where: 'role = ? AND actif = ?',
        whereArgs: [role, 1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Utilisateur.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des utilisateurs: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour un utilisateur
  Future<int> mettreAJourUtilisateur(Utilisateur utilisateur) async {
    try {
      final db = await _db.database;
      return await db.update(
        'utilisateurs',
        utilisateur.toMap(),
        where: 'id = ?',
        whereArgs: [utilisateur.id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour de l\'utilisateur: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour la dernière connexion
  Future<int> mettreAJourDerniereConnexion(int utilisateurId) async {
    try {
      final db = await _db.database;

      // Récupérer le nombre de connexions actuel
      final user = await getUtilisateurById(utilisateurId);
      if (user == null) {
        throw AppDatabaseException('Utilisateur non trouvé');
      }

      return await db.update(
        'utilisateurs',
        {
          'derniere_connexion': DateTime.now().toIso8601String(),
          'nombre_connexions': user.nombreConnexions + 1,
        },
        where: 'id = ?',
        whereArgs: [utilisateurId],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour de la connexion: $e',
      );
    }
  }

  /// UPDATE - Changer le code PIN
  Future<int> changerCodePIN(int utilisateurId, String nouveauPINHash) async {
    try {
      final db = await _db.database;
      return await db.update(
        'utilisateurs',
        {'code_pin': nouveauPINHash},
        where: 'id = ?',
        whereArgs: [utilisateurId],
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors du changement de code PIN: $e');
    }
  }

  /// UPDATE - Activer/Désactiver un utilisateur
  Future<int> toggleActif(int utilisateurId, bool actif) async {
    try {
      final db = await _db.database;
      return await db.update(
        'utilisateurs',
        {'actif': actif ? 1 : 0},
        where: 'id = ?',
        whereArgs: [utilisateurId],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la modification du statut: $e',
      );
    }
  }

  /// DELETE - Supprimer un utilisateur (soft delete)
  Future<int> supprimerUtilisateur(int id) async {
    try {
      final db = await _db.database;
      return await db.update(
        'utilisateurs',
        {'actif': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression de l\'utilisateur: $e',
      );
    }
  }

  /// DELETE - Supprimer définitivement un utilisateur
  Future<int> supprimerUtilisateurDefinitivement(int id) async {
    try {
      final db = await _db.database;
      return await db.delete('utilisateurs', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression définitive: $e',
      );
    }
  }

  /// STATS - Compter les utilisateurs par rôle
  Future<Map<String, int>> compterUtilisateursParRole() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT role, COUNT(*) as count
        FROM utilisateurs
        WHERE actif = 1
        GROUP BY role
      ''');

      Map<String, int> stats = {};
      for (var row in result) {
        stats[row['role'] as String] = row['count'] as int;
      }

      return stats;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors du comptage des utilisateurs: $e',
      );
    }
  }

  /// VERIFICATION - Vérifier si un code PIN existe déjà
  Future<bool> codePINExiste(String pinHash, {int? excludeUserId}) async {
    try {
      final db = await _db.database;

      String whereClause = 'code_pin = ?';
      List<dynamic> whereArgs = [pinHash];

      if (excludeUserId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeUserId);
      }

      final result = await db.query(
        'utilisateurs',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la vérification du code PIN: $e',
      );
    }
  }
}
