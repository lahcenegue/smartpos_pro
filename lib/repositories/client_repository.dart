import '../core/services/database_service.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/helpers.dart';
import '../models/client.dart';

/// Repository pour la gestion des clients
class ClientRepository {
  final DatabaseService _db = DatabaseService.instance;

  /// CREATE - Créer un nouveau client
  Future<int> creerClient(Client client) async {
    try {
      final db = await _db.database;

      // Générer un code client si non fourni
      Map<String, dynamic> clientData = client.toMap();
      if (clientData['code_client'] == null) {
        clientData['code_client'] = Helpers.generateCode('CLI');
      }

      return await db.insert('clients', clientData);
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la création du client: $e');
    }
  }

  /// READ - Récupérer tous les clients actifs
  Future<List<Client>> getTousClients() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'actif = ?',
        whereArgs: [1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des clients: $e',
      );
    }
  }

  /// READ - Récupérer un client par ID
  Future<Client?> getClientById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Client.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération du client: $e',
      );
    }
  }

  /// READ - Récupérer un client par code
  Future<Client?> getClientByCode(String codeClient) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'code_client = ?',
        whereArgs: [codeClient],
      );

      if (maps.isEmpty) return null;
      return Client.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération du client: $e',
      );
    }
  }

  /// READ - Rechercher des clients
  Future<List<Client>> rechercherClients(String query) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where:
            'actif = ? AND (nom LIKE ? OR prenom LIKE ? OR telephone LIKE ? OR email LIKE ? OR entreprise LIKE ?)',
        whereArgs: [
          1,
          '%$query%',
          '%$query%',
          '%$query%',
          '%$query%',
          '%$query%',
        ],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la recherche de clients: $e');
    }
  }

  /// READ - Récupérer les clients par type
  Future<List<Client>> getClientsByType(String typeClient) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'type_client = ? AND actif = ?',
        whereArgs: [typeClient, 1],
        orderBy: 'nom ASC',
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des clients: $e',
      );
    }
  }

  /// READ - Récupérer les clients VIP
  Future<List<Client>> getClientsVIP() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'type_client = ? AND actif = ?',
        whereArgs: ['vip', 1],
        orderBy: 'total_achats DESC',
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des clients VIP: $e',
      );
    }
  }

  /// READ - Récupérer les clients avec dette
  Future<List<Client>> getClientsAvecDette() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'dette > 0 AND actif = ?',
        whereArgs: [1],
        orderBy: 'dette DESC',
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des clients: $e',
      );
    }
  }

  /// READ - Récupérer les meilleurs clients
  Future<List<Client>> getMeilleursClients({int limit = 10}) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'actif = ?',
        whereArgs: [1],
        orderBy: 'total_achats DESC',
        limit: limit,
      );
      return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des meilleurs clients: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour un client
  Future<int> mettreAJourClient(Client client) async {
    try {
      final db = await _db.database;
      return await db.update(
        'clients',
        client.toMap(),
        where: 'id = ?',
        whereArgs: [client.id],
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la mise à jour du client: $e');
    }
  }

  /// UPDATE - Mettre à jour les points de fidélité
  Future<int> mettreAJourPoints(int clientId, int nouveauxPoints) async {
    try {
      final db = await _db.database;
      return await db.update(
        'clients',
        {
          'points_fidelite': nouveauxPoints,
          'date_modification': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [clientId],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour des points: $e',
      );
    }
  }

  /// UPDATE - Ajouter des points de fidélité
  Future<int> ajouterPoints(int clientId, int pointsAjoutes) async {
    try {
      final db = await _db.database;

      // Récupérer les points actuels
      final client = await getClientById(clientId);
      if (client == null) {
        throw AppDatabaseException('Client non trouvé');
      }

      return await mettreAJourPoints(
        clientId,
        client.pointsFidelite + pointsAjoutes,
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors de l\'ajout de points: $e');
    }
  }

  /// UPDATE - Utiliser des points de fidélité
  Future<int> utiliserPoints(int clientId, int pointsUtilises) async {
    try {
      final db = await _db.database;

      // Récupérer les points actuels
      final client = await getClientById(clientId);
      if (client == null) {
        throw AppDatabaseException('Client non trouvé');
      }

      if (client.pointsFidelite < pointsUtilises) {
        throw ValidationException('Points insuffisants');
      }

      return await mettreAJourPoints(
        clientId,
        client.pointsFidelite - pointsUtilises,
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de l\'utilisation des points: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour la dette
  Future<int> mettreAJourDette(int clientId, double nouvelleDette) async {
    try {
      final db = await _db.database;
      return await db.update(
        'clients',
        {
          'dette': nouvelleDette,
          'date_modification': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [clientId],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour de la dette: $e',
      );
    }
  }

  /// UPDATE - Bloquer/Débloquer un client
  Future<int> toggleBloquer(int clientId, bool bloquer) async {
    try {
      final db = await _db.database;
      return await db.update(
        'clients',
        {'bloque': bloquer ? 1 : 0},
        where: 'id = ?',
        whereArgs: [clientId],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la modification du statut: $e',
      );
    }
  }

  /// DELETE - Supprimer un client (soft delete)
  Future<int> supprimerClient(int id) async {
    try {
      final db = await _db.database;
      return await db.update(
        'clients',
        {'actif': 0, 'date_modification': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la suppression du client: $e');
    }
  }

  /// DELETE - Supprimer définitivement un client
  Future<int> supprimerClientDefinitivement(int id) async {
    try {
      final db = await _db.database;
      return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la suppression définitive: $e',
      );
    }
  }

  /// STATS - Statistiques des clients
  Future<Map<String, dynamic>> getStatistiquesClients() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT
          COUNT(*) as total_clients,
          COUNT(CASE WHEN type_client = 'vip' THEN 1 END) as clients_vip,
          COUNT(CASE WHEN dette > 0 THEN 1 END) as clients_avec_dette,
          COALESCE(SUM(dette), 0) as dette_totale,
          COALESCE(SUM(total_achats), 0) as ca_total,
          COALESCE(AVG(panier_moyen), 0) as panier_moyen_global
        FROM clients
        WHERE actif = 1
      ''');

      return result.first;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// STATS - Compter les clients par type
  Future<Map<String, int>> compterClientsParType() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT type_client, COUNT(*) as count
        FROM clients
        WHERE actif = 1
        GROUP BY type_client
      ''');

      Map<String, int> stats = {};
      for (var row in result) {
        stats[row['type_client'] as String] = row['count'] as int;
      }

      return stats;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du comptage des clients: $e');
    }
  }

  /// VERIFICATION - Vérifier si un téléphone existe
  Future<bool> telephoneExiste(String telephone, {int? excludeClientId}) async {
    try {
      final db = await _db.database;

      String whereClause = 'telephone = ?';
      List<dynamic> whereArgs = [telephone];

      if (excludeClientId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeClientId);
      }

      final result = await db.query(
        'clients',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la vérification du téléphone: $e',
      );
    }
  }

  /// VERIFICATION - Vérifier si un email existe
  Future<bool> emailExiste(String email, {int? excludeClientId}) async {
    try {
      final db = await _db.database;

      String whereClause = 'email = ?';
      List<dynamic> whereArgs = [email];

      if (excludeClientId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeClientId);
      }

      final result = await db.query(
        'clients',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la vérification de l\'email: $e',
      );
    }
  }
}
