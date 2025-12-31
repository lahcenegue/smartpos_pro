import 'package:smartpos_pro/core/constants/app_constants.dart';

import '../core/services/database_service.dart';
import '../core/errors/exceptions.dart';
import '../models/vente.dart';
import '../models/ligne_vente.dart';

/// Repository pour la gestion des ventes
class VenteRepository {
  final DatabaseService _db = DatabaseService.instance;

  /// CREATE - Créer une nouvelle vente (avec ses lignes)
  Future<int> creerVente(Vente vente) async {
    try {
      final db = await _db.database;

      // 🔍 DEBUG : Vérifier que l'utilisateur existe
      final userCheck = await db.query(
        'utilisateurs',
        where: 'id = ?',
        whereArgs: [vente.utilisateurId],
      );

      if (userCheck.isEmpty) {
        throw AppDatabaseException(
          'Utilisateur ID ${vente.utilisateurId} n\'existe pas !',
        );
      }

      // 🔍 DEBUG : Si client, vérifier qu'il existe
      if (vente.clientId != null) {
        final clientCheck = await db.query(
          'clients',
          where: 'id = ?',
          whereArgs: [vente.clientId],
        );

        if (clientCheck.isEmpty) {
          throw AppDatabaseException(
            'Client ID ${vente.clientId} n\'existe pas !',
          );
        }
      }

      print('=== DEBUG REPOSITORY ===');
      print('Utilisateur vérifié: ${vente.utilisateurId}');
      print('Client vérifié: ${vente.clientId}');
      print('Numero facture: ${vente.numeroFacture}');
      print('Type document: ${vente.typeDocument}');
      print('Map vente: ${vente.toMap()}');
      print('========================');

      // Utiliser une transaction pour garantir l'intégrité
      return await db.transaction((txn) async {
        // Insérer la vente
        final venteId = await txn.insert('ventes', vente.toMap());

        print('Vente insérée avec ID: $venteId');

        // Insérer toutes les lignes de vente
        for (var ligne in vente.lignes) {
          await txn.insert(
            'lignes_vente',
            ligne.copyWith(venteId: venteId).toMap(),
          );
        }

        // Mettre à jour la session de caisse si applicable
        if (vente.sessionCaisseId != null) {
          await _mettreAJourSessionCaisse(txn, vente);
        }

        return venteId;
      });
    } catch (e) {
      print('=== ERREUR REPOSITORY ===');
      print(e);
      print('=========================');
      throw AppDatabaseException('Erreur lors de la création de la vente: $e');
    }
  }

  /// Mettre à jour les statistiques de la session de caisse
  Future<void> _mettreAJourSessionCaisse(dynamic txn, Vente vente) async {
    // Récupérer les totaux actuels de la session
    final sessionResult = await txn.query(
      'sessions_caisse',
      where: 'id = ?',
      whereArgs: [vente.sessionCaisseId],
    );

    if (sessionResult.isEmpty) return;

    final session = sessionResult.first;
    final nombreVentes = (session['nombre_ventes'] as int) + 1;
    final montantTotal =
        (session['montant_total_ventes'] as double) + vente.montantTTC;

    double totalEspeces = session['total_especes'] as double;
    double totalCarte = session['total_carte'] as double;
    double totalCheque = session['total_cheque'] as double;

    // Ajouter les montants selon le mode de paiement
    if (vente.modePaiement == 'especes' || vente.modePaiement == 'mixte') {
      totalEspeces += vente.montantEspeces;
    }
    if (vente.modePaiement == 'carte' || vente.modePaiement == 'mixte') {
      totalCarte += vente.montantCarte;
    }
    if (vente.modePaiement == 'cheque' || vente.modePaiement == 'mixte') {
      totalCheque += vente.montantCheque;
    }

    // Mettre à jour la session
    await txn.update(
      'sessions_caisse',
      {
        'nombre_ventes': nombreVentes,
        'montant_total_ventes': montantTotal,
        'total_especes': totalEspeces,
        'total_carte': totalCarte,
        'total_cheque': totalCheque,
      },
      where: 'id = ?',
      whereArgs: [vente.sessionCaisseId],
    );
  }

  /// READ - Toutes les ventes (avec limite)
  Future<List<Vente>> getToutesVentes({int? limit}) async {
    try {
      final db = await _db.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        orderBy: 'date_vente DESC',
        limit: limit,
      );

      List<Vente> ventes = [];
      for (var map in maps) {
        final lignes = await getLignesVente(map['id']);
        ventes.add(Vente.fromMap(map, lignes: lignes));
      }

      return ventes;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des ventes: $e',
      );
    }
  }

  /// READ - Ventes par période
  Future<List<Vente>> getVentesParPeriode(DateTime debut, DateTime fin) async {
    try {
      final db = await _db.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'date_vente BETWEEN ? AND ?',
        whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
        orderBy: 'date_vente DESC',
      );

      List<Vente> ventes = [];
      for (var map in maps) {
        final lignes = await getLignesVente(map['id']);
        ventes.add(Vente.fromMap(map, lignes: lignes));
      }

      return ventes;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des ventes: $e',
      );
    }
  }

  /// READ - Récupérer une vente par ID
  Future<Vente?> getVenteById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final lignes = await getLignesVente(id);
      return Vente.fromMap(maps.first, lignes: lignes);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération de la vente: $e',
      );
    }
  }

  /// READ - Récupérer une vente par numéro de facture
  Future<Vente?> getVenteByNumeroFacture(String numeroFacture) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'numero_facture = ?',
        whereArgs: [numeroFacture],
      );

      if (maps.isEmpty) return null;

      final lignes = await getLignesVente(maps.first['id']);
      return Vente.fromMap(maps.first, lignes: lignes);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération de la vente: $e',
      );
    }
  }

  /// READ - Récupérer les lignes d'une vente
  Future<List<LigneVente>> getLignesVente(int venteId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'lignes_vente',
        where: 'vente_id = ?',
        whereArgs: [venteId],
        orderBy: 'ordre ASC',
      );

      return List.generate(maps.length, (i) => LigneVente.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des lignes: $e',
      );
    }
  }

  /// READ - Récupérer les ventes par client
  Future<List<Vente>> getVentesByClient(int clientId, {int? limit}) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'client_id = ?',
        whereArgs: [clientId],
        orderBy: 'date_vente DESC',
        limit: limit,
      );

      List<Vente> ventes = [];
      for (var map in maps) {
        final lignes = await getLignesVente(map['id']);
        ventes.add(Vente.fromMap(map, lignes: lignes));
      }

      return ventes;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des ventes: $e',
      );
    }
  }

  /// READ - Récupérer les ventes par période
  Future<List<Vente>> getVentesByPeriode({
    required DateTime debut,
    required DateTime fin,
  }) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'date_vente >= ? AND date_vente <= ?',
        whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
        orderBy: 'date_vente DESC',
      );

      List<Vente> ventes = [];
      for (var map in maps) {
        final lignes = await getLignesVente(map['id']);
        ventes.add(Vente.fromMap(map, lignes: lignes));
      }

      return ventes;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des ventes: $e',
      );
    }
  }

  /// READ - Récupérer les ventes du jour
  Future<List<Vente>> getVentesDuJour() async {
    final maintenant = DateTime.now();
    final debut = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final fin = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
      23,
      59,
      59,
    );

    return await getVentesByPeriode(debut: debut, fin: fin);
  }

  /// READ - Ventes en attente
  Future<List<Vente>> getVentesEnAttente() async {
    try {
      final db = await _db.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'ventes',
        where: 'statut = ?',
        whereArgs: ['en_attente'],
        orderBy: 'date_vente DESC',
      );

      // Charger chaque vente avec ses lignes
      List<Vente> ventes = [];
      for (var map in maps) {
        final lignes = await getLignesVente(map['id']);
        ventes.add(Vente.fromMap(map, lignes: lignes));
      }

      return ventes;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des ventes en attente: $e',
      );
    }
  }

  /// UPDATE - Mettre à jour une vente
  Future<int> mettreAJourVente(Vente vente) async {
    try {
      final db = await _db.database;
      return await db.update(
        'ventes',
        vente.toMap(),
        where: 'id = ?',
        whereArgs: [vente.id],
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la mise à jour de la vente: $e',
      );
    }
  }

  /// UPDATE - Marquer une vente comme imprimée
  Future<int> marquerCommeImprimee(int venteId) async {
    try {
      final db = await _db.database;
      return await db.update(
        'ventes',
        {'imprimee': 1},
        where: 'id = ?',
        whereArgs: [venteId],
      );
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la mise à jour: $e');
    }
  }

  /// UPDATE - Annuler une vente
  Future<int> annulerVente(int id, String motif, int utilisateurId) async {
    try {
      final db = await _db.database;

      return await db.transaction((txn) async {
        // Récupérer la vente avec ses lignes
        final venteMap = await txn.query(
          'ventes',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (venteMap.isEmpty) {
          throw AppDatabaseException('Vente introuvable');
        }

        final vente = venteMap.first;

        // Vérifier que la vente n'est pas déjà annulée
        if (vente['statut'] == AppConstants.venteAnnulee) {
          throw AppDatabaseException('Cette vente est déjà annulée');
        }

        // Récupérer les lignes de vente
        final lignes = await txn.query(
          'lignes_vente',
          where: 'vente_id = ?',
          whereArgs: [id],
        );

        // Remettre le stock de chaque produit
        for (var ligne in lignes) {
          final produitId = ligne['produit_id'] as int;
          final quantite = ligne['quantite'] as double;

          // Remettre le stock
          await txn.rawUpdate(
            'UPDATE produits SET stock = stock + ? WHERE id = ?',
            [quantite.toInt(), produitId],
          );

          // Remettre en_rupture à 0 si stock > 0
          await txn.rawUpdate(
            'UPDATE produits SET en_rupture = 0 WHERE id = ? AND stock > 0',
            [produitId],
          );

          // Créer un mouvement de stock
          await txn.insert('mouvements_stock', {
            'produit_id': produitId,
            'type': AppConstants.mouvementRetour,
            'quantite': quantite,
            'stock_avant': 0, // TODO: récupérer le vrai stock avant
            'stock_apres': 0, // TODO: récupérer le vrai stock après
            'motif': 'Annulation vente ${vente['numero_facture']}',
            'reference': vente['numero_facture'],
            'utilisateur_id': utilisateurId,
            'vente_id': id,
            'date_mouvement': DateTime.now().toIso8601String(),
          });
        }

        // Annuler les points de fidélité si client
        if (vente['client_id'] != null) {
          final clientId = vente['client_id'] as int;
          final pointsGagnes = vente['points_gagnes'] as int;

          if (pointsGagnes > 0) {
            // Récupérer le solde actuel
            final clientMap = await txn.query(
              'clients',
              columns: ['points_fidelite'],
              where: 'id = ?',
              whereArgs: [clientId],
            );

            final soldeAvant = clientMap.first['points_fidelite'] as int;
            final soldeApres = soldeAvant - pointsGagnes;

            // Retirer les points
            await txn.update(
              'clients',
              {'points_fidelite': soldeApres >= 0 ? soldeApres : 0},
              where: 'id = ?',
              whereArgs: [clientId],
            );

            // Enregistrer la transaction de points
            await txn.insert('points_fidelite', {
              'client_id': clientId,
              'type': 'ajustement',
              'points': -pointsGagnes,
              'vente_id': id,
              'motif': 'Annulation vente',
              'solde_avant': soldeAvant,
              'solde_apres': soldeApres >= 0 ? soldeApres : 0,
              'date_transaction': DateTime.now().toIso8601String(),
            });
          }
        }

        // Marquer la vente comme annulée
        return await txn.update(
          'ventes',
          {
            'statut': AppConstants.venteAnnulee,
            'motif_annulation': motif,
            'date_annulation': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      print('❌ Erreur annulation vente: $e');
      throw AppDatabaseException(
        'Erreur lors de l\'annulation de la vente: $e',
      );
    }
  }

  /// DELETE - Supprimer une vente (avec ses lignes)
  Future<int> supprimerVente(int id) async {
    try {
      final db = await _db.database;

      print('🗑️ Début suppression vente $id...');

      // Étape 1 : Compter les lignes à supprimer
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lignes_vente WHERE vente_id = ?',
        [id],
      );
      final nbLignes = countResult.first['count'] as int;
      print('📋 $nbLignes ligne(s) à supprimer');

      // Étape 2 : Supprimer les lignes SANS transaction d'abord
      final lignesDeleted = await db.delete(
        'lignes_vente',
        where: 'vente_id = ?',
        whereArgs: [id],
      );
      print('✅ $lignesDeleted ligne(s) supprimée(s)');

      // Étape 3 : Vérifier qu'il ne reste plus de lignes
      final verif = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lignes_vente WHERE vente_id = ?',
        [id],
      );
      final restant = verif.first['count'] as int;

      if (restant > 0) {
        throw AppDatabaseException(
          'Impossible de supprimer toutes les lignes de vente',
        );
      }

      print('✅ Toutes les lignes supprimées, suppression de la vente...');

      // Étape 4 : Maintenant supprimer la vente
      final result = await db.delete(
        'ventes',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Vente $id supprimée avec succès');
      return result;
    } catch (e) {
      print('❌ Erreur suppression vente $id: $e');
      throw AppDatabaseException(
        'Erreur lors de la suppression de la vente: $e',
      );
    }
  }

  /// STATS - Statistiques des ventes du jour
  Future<Map<String, dynamic>> getStatistiquesJour() async {
    try {
      final db = await _db.database;
      final maintenant = DateTime.now();
      final debut = DateTime(maintenant.year, maintenant.month, maintenant.day);

      final result = await db.rawQuery(
        '''
        SELECT
          COUNT(*) as nombre_ventes,
          COALESCE(SUM(montant_ttc), 0) as ca_total,
          COALESCE(AVG(montant_ttc), 0) as panier_moyen,
          COALESCE(SUM(CASE WHEN mode_paiement = 'especes' THEN montant_ttc ELSE 0 END), 0) as ca_especes,
          COALESCE(SUM(CASE WHEN mode_paiement = 'carte' THEN montant_ttc ELSE 0 END), 0) as ca_carte,
          COALESCE(SUM(CASE WHEN mode_paiement = 'cheque' THEN montant_ttc ELSE 0 END), 0) as ca_cheque
        FROM ventes
        WHERE statut = 'terminee'
        AND date_vente >= ?
      ''',
        [debut.toIso8601String()],
      );

      return result.first;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// STATS - Statistiques par période
  Future<Map<String, dynamic>> getStatistiquesPeriode({
    required DateTime debut,
    required DateTime fin,
  }) async {
    try {
      final db = await _db.database;

      final result = await db.rawQuery(
        '''
        SELECT
          COUNT(*) as nombre_ventes,
          COALESCE(SUM(montant_ttc), 0) as ca_total,
          COALESCE(AVG(montant_ttc), 0) as panier_moyen,
          COALESCE(SUM(montant_ht), 0) as total_ht,
          COALESCE(SUM(montant_tva), 0) as total_tva,
          COALESCE(SUM(montant_remise), 0) as total_remises
        FROM ventes
        WHERE statut = 'terminee'
        AND date_vente >= ? AND date_vente <= ?
      ''',
        [debut.toIso8601String(), fin.toIso8601String()],
      );

      return result.first;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// STATS - Top produits vendus
  Future<List<Map<String, dynamic>>> getTopProduitsVendus({
    int limit = 10,
    DateTime? debut,
    DateTime? fin,
  }) async {
    try {
      final db = await _db.database;

      String whereClause = 'v.statut = ?';
      List<dynamic> whereArgs = ['terminee'];

      if (debut != null && fin != null) {
        whereClause += ' AND v.date_vente >= ? AND v.date_vente <= ?';
        whereArgs.addAll([debut.toIso8601String(), fin.toIso8601String()]);
      }

      final result = await db.rawQuery(
        '''
        SELECT
          lv.produit_id,
          lv.nom_produit,
          SUM(lv.quantite) as quantite_totale,
          SUM(lv.total_ttc) as ca_total,
          COUNT(DISTINCT lv.vente_id) as nombre_ventes
        FROM lignes_vente lv
        INNER JOIN ventes v ON lv.vente_id = v.id
        WHERE $whereClause
        GROUP BY lv.produit_id
        ORDER BY quantite_totale DESC
        LIMIT ?
      ''',
        [...whereArgs, limit],
      );

      return result;
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération du top produits: $e',
      );
    }
  }

  /// STATS - Ventes par heure (pour analyse)
  Future<List<Map<String, dynamic>>> getVentesParHeure(DateTime date) async {
    try {
      final db = await _db.database;
      final debut = DateTime(date.year, date.month, date.day);
      final fin = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final result = await db.rawQuery(
        '''
        SELECT
          CAST(strftime('%H', date_vente) AS INTEGER) as heure,
          COUNT(*) as nombre_ventes,
          COALESCE(SUM(montant_ttc), 0) as ca
        FROM ventes
        WHERE statut = 'terminee'
        AND date_vente >= ? AND date_vente <= ?
        GROUP BY heure
        ORDER BY heure
      ''',
        [debut.toIso8601String(), fin.toIso8601String()],
      );

      return result;
    } catch (e) {
      throw AppDatabaseException('Erreur lors de l\'analyse horaire: $e');
    }
  }
}
