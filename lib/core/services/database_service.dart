import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Service de gestion de la base de données SQLite
///
/// Singleton qui gère la création, l'initialisation et l'accès à la base de données
/// Toutes les tables sont créées selon le schéma défini dans DATABASE_SCHEMA.md
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  /// Initialiser la base de données
  Future<Database> _initDB(String filePath) async {
    try {
      // Obtenir le chemin Documents
      final docsPath = await getApplicationDocumentsDirectory();
      final appPath = join(docsPath.path, AppConstants.appFolderName);

      // Créer le dossier s'il n'existe pas
      await Directory(appPath).create(recursive: true);

      final path = join(appPath, filePath);

      print('📂 Chemin de la base de données: $path');

      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de l\'initialisation de la base de données: $e',
      );
    }
  }

  /// Configuration de la base de données
  Future<void> _onConfigure(Database db) async {
    // Activer les clés étrangères
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Créer toutes les tables de la base de données
  Future<void> _createDB(Database db, int version) async {
    print('🔨 Création de la base de données version $version...');

    // ==================== MODULE PRODUITS ====================

    // Table: categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        parent_id INTEGER,
        couleur TEXT DEFAULT '#2196F3',
        icone TEXT DEFAULT 'category',
        ordre INTEGER DEFAULT 0,
        description TEXT,
        actif INTEGER DEFAULT 1,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_categories_parent ON categories(parent_id)',
    );
    await db.execute('CREATE INDEX idx_categories_actif ON categories(actif)');

    // Table: produits
    await db.execute('''
      CREATE TABLE produits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_barre TEXT UNIQUE,
        reference TEXT,
        nom TEXT NOT NULL,
        description TEXT,
        categorie_id INTEGER,
        prix_achat REAL DEFAULT 0,
        prix_vente REAL NOT NULL,
        prix_promotion REAL,
        tva_taux REAL DEFAULT ${AppConstants.tauxTVANormal},
        stock INTEGER DEFAULT 0,
        stock_minimum INTEGER DEFAULT ${AppConstants.stockMinimumDefaut},
        stock_maximum INTEGER,
        unite TEXT DEFAULT 'unité',
        marque TEXT,
        image_path TEXT,
        a_variantes INTEGER DEFAULT 0,
        poids REAL,
        actif INTEGER DEFAULT 1,
        en_promotion INTEGER DEFAULT 0,
        en_rupture INTEGER DEFAULT 0,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
        utilisateur_creation_id INTEGER,
        FOREIGN KEY (categorie_id) REFERENCES categories(id),
        FOREIGN KEY (utilisateur_creation_id) REFERENCES utilisateurs(id),
        CHECK (prix_vente >= 0),
        CHECK (prix_achat >= 0),
        CHECK (stock >= 0),
        CHECK (tva_taux >= 0 AND tva_taux <= 100)
      )
    ''');

    await db.execute('CREATE INDEX idx_produits_nom ON produits(nom)');
    await db.execute(
      'CREATE INDEX idx_produits_code_barre ON produits(code_barre)',
    );
    await db.execute(
      'CREATE INDEX idx_produits_categorie ON produits(categorie_id)',
    );
    await db.execute('CREATE INDEX idx_produits_actif ON produits(actif)');
    await db.execute(
      'CREATE INDEX idx_produits_en_rupture ON produits(en_rupture)',
    );

    // Table: variantes_produits
    await db.execute('''
      CREATE TABLE variantes_produits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produit_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        code_barre TEXT UNIQUE,
        reference TEXT,
        prix_supplement REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        couleur TEXT,
        taille TEXT,
        image_path TEXT,
        actif INTEGER DEFAULT 1,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE,
        CHECK (stock >= 0)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_variantes_produit ON variantes_produits(produit_id)',
    );
    await db.execute(
      'CREATE INDEX idx_variantes_code_barre ON variantes_produits(code_barre)',
    );

    // ==================== MODULE VENTES ====================

    // Table: sessions_caisse
    await db.execute('''
      CREATE TABLE sessions_caisse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        date_ouverture DATETIME DEFAULT CURRENT_TIMESTAMP,
        montant_ouverture REAL DEFAULT 0,
        date_fermeture DATETIME,
        montant_fermeture REAL,
        montant_theorique REAL,
        ecart REAL,
        total_especes REAL DEFAULT 0,
        total_carte REAL DEFAULT 0,
        total_cheque REAL DEFAULT 0,
        nombre_ventes INTEGER DEFAULT 0,
        montant_total_ventes REAL DEFAULT 0,
        statut TEXT DEFAULT 'ouverte',
        notes_ouverture TEXT,
        notes_fermeture TEXT,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
        CHECK (statut IN ('ouverte', 'fermee'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sessions_utilisateur ON sessions_caisse(utilisateur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_date_ouverture ON sessions_caisse(date_ouverture)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_statut ON sessions_caisse(statut)',
    );

    // Table: ventes
    await db.execute('''
      CREATE TABLE ventes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_facture TEXT UNIQUE NOT NULL,
        numero_ticket TEXT,
        client_id INTEGER,
        utilisateur_id INTEGER NOT NULL,
        session_caisse_id INTEGER,
        montant_ht REAL DEFAULT 0,
        montant_tva REAL DEFAULT 0,
        montant_ttc REAL NOT NULL,
        montant_remise REAL DEFAULT 0,
        remise_pourcentage REAL DEFAULT 0,
        mode_paiement TEXT NOT NULL,
        montant_especes REAL DEFAULT 0,
        montant_carte REAL DEFAULT 0,
        montant_cheque REAL DEFAULT 0,
        montant_credit REAL DEFAULT 0,
        montant_paye REAL DEFAULT 0,
        montant_rendu REAL DEFAULT 0,
        points_utilises INTEGER DEFAULT 0,
        points_gagnes INTEGER DEFAULT 0,
        statut TEXT DEFAULT '${AppConstants.venteTerminee}',
        motif_annulation TEXT,
        date_vente DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_annulation DATETIME,
        notes TEXT,
        imprimee INTEGER DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
        FOREIGN KEY (session_caisse_id) REFERENCES sessions_caisse(id),
        CHECK (montant_ttc >= 0),
        CHECK (mode_paiement IN ('${AppConstants.paiementEspeces}', '${AppConstants.paiementCarte}', '${AppConstants.paiementCheque}', '${AppConstants.paiementMixte}', '${AppConstants.paiementCredit}'))
      )
    ''');

    await db.execute('CREATE INDEX idx_ventes_date ON ventes(date_vente)');
    await db.execute('CREATE INDEX idx_ventes_client ON ventes(client_id)');
    await db.execute(
      'CREATE INDEX idx_ventes_utilisateur ON ventes(utilisateur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_ventes_numero_facture ON ventes(numero_facture)',
    );
    await db.execute('CREATE INDEX idx_ventes_statut ON ventes(statut)');
    await db.execute(
      'CREATE INDEX idx_ventes_session ON ventes(session_caisse_id)',
    );

    // Table: lignes_vente
    await db.execute('''
      CREATE TABLE lignes_vente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vente_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        variante_id INTEGER,
        nom_produit TEXT NOT NULL,
        code_barre TEXT,
        quantite REAL NOT NULL,
        prix_unitaire_ht REAL NOT NULL,
        prix_unitaire_ttc REAL NOT NULL,
        tva_taux REAL NOT NULL,
        remise_ligne REAL DEFAULT 0,
        remise_pourcentage REAL DEFAULT 0,
        total_ht REAL NOT NULL,
        total_tva REAL NOT NULL,
        total_ttc REAL NOT NULL,
        ordre INTEGER DEFAULT 0,
        FOREIGN KEY (vente_id) REFERENCES ventes(id) ON DELETE CASCADE,
        FOREIGN KEY (produit_id) REFERENCES produits(id),
        FOREIGN KEY (variante_id) REFERENCES variantes_produits(id),
        CHECK (quantite > 0),
        CHECK (prix_unitaire_ttc >= 0),
        CHECK (total_ttc >= 0)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_lignes_vente_vente ON lignes_vente(vente_id)',
    );
    await db.execute(
      'CREATE INDEX idx_lignes_vente_produit ON lignes_vente(produit_id)',
    );

    // ==================== MODULE STOCK ====================

    // Table: mouvements_stock
    await db.execute('''
      CREATE TABLE mouvements_stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produit_id INTEGER NOT NULL,
        variante_id INTEGER,
        type TEXT NOT NULL,
        quantite REAL NOT NULL,
        stock_avant REAL NOT NULL,
        stock_apres REAL NOT NULL,
        motif TEXT,
        reference TEXT,
        utilisateur_id INTEGER,
        vente_id INTEGER,
        reception_id INTEGER,
        date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (produit_id) REFERENCES produits(id),
        FOREIGN KEY (variante_id) REFERENCES variantes_produits(id),
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
        FOREIGN KEY (vente_id) REFERENCES ventes(id),
        CHECK (type IN ('${AppConstants.mouvementEntree}', '${AppConstants.mouvementSortie}', '${AppConstants.mouvementAjustement}', '${AppConstants.mouvementVente}', '${AppConstants.mouvementRetour}', '${AppConstants.mouvementPerte}'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_mouvements_produit ON mouvements_stock(produit_id)',
    );
    await db.execute(
      'CREATE INDEX idx_mouvements_date ON mouvements_stock(date_mouvement)',
    );
    await db.execute(
      'CREATE INDEX idx_mouvements_type ON mouvements_stock(type)',
    );
    await db.execute(
      'CREATE INDEX idx_mouvements_utilisateur ON mouvements_stock(utilisateur_id)',
    );

    // Table: inventaires
    await db.execute('''
      CREATE TABLE inventaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_inventaire DATETIME DEFAULT CURRENT_TIMESTAMP,
        utilisateur_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        nombre_produits INTEGER DEFAULT 0,
        valeur_totale_achat REAL DEFAULT 0,
        valeur_totale_vente REAL DEFAULT 0,
        statut TEXT DEFAULT 'en_cours',
        date_validation DATETIME,
        notes TEXT,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
        CHECK (statut IN ('en_cours', 'valide', 'annule'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_inventaires_date ON inventaires(date_inventaire)',
    );

    // Table: lignes_inventaire
    await db.execute('''
      CREATE TABLE lignes_inventaire (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inventaire_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        variante_id INTEGER,
        stock_systeme REAL NOT NULL,
        stock_physique REAL NOT NULL,
        ecart REAL NOT NULL,
        prix_achat REAL,
        prix_vente REAL,
        FOREIGN KEY (inventaire_id) REFERENCES inventaires(id) ON DELETE CASCADE,
        FOREIGN KEY (produit_id) REFERENCES produits(id),
        FOREIGN KEY (variante_id) REFERENCES variantes_produits(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_lignes_inventaire_inventaire ON lignes_inventaire(inventaire_id)',
    );

    // ==================== MODULE CLIENTS ====================

    // Table: clients
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_client TEXT UNIQUE,
        nom TEXT NOT NULL,
        prenom TEXT,
        entreprise TEXT,
        telephone TEXT,
        telephone_2 TEXT,
        email TEXT,
        adresse TEXT,
        ville TEXT,
        code_postal TEXT,
        pays TEXT DEFAULT 'Algérie',
        type_client TEXT DEFAULT '${AppConstants.clientParticulier}',
        niveau_fidelite TEXT DEFAULT '${AppConstants.fideliteBronze}',
        credit REAL DEFAULT 0,
        dette REAL DEFAULT 0,
        plafond_credit REAL DEFAULT 0,
        points_fidelite INTEGER DEFAULT 0,
        total_achats REAL DEFAULT 0,
        nombre_achats INTEGER DEFAULT 0,
        date_dernier_achat DATETIME,
        panier_moyen REAL DEFAULT 0,
        actif INTEGER DEFAULT 1,
        bloque INTEGER DEFAULT 0,
        accepte_marketing INTEGER DEFAULT 0,
        date_naissance DATE,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        CHECK (type_client IN ('${AppConstants.clientParticulier}', '${AppConstants.clientProfessionnel}', '${AppConstants.clientVIP}')),
        CHECK (niveau_fidelite IN ('${AppConstants.fideliteBronze}', '${AppConstants.fideliteArgent}', '${AppConstants.fideliteOr}', '${AppConstants.fidelitePlatine}')),
        CHECK (points_fidelite >= 0),
        CHECK (credit >= 0)
      )
    ''');

    await db.execute('CREATE INDEX idx_clients_nom ON clients(nom)');
    await db.execute(
      'CREATE INDEX idx_clients_telephone ON clients(telephone)',
    );
    await db.execute('CREATE INDEX idx_clients_email ON clients(email)');
    await db.execute('CREATE INDEX idx_clients_code ON clients(code_client)');
    await db.execute('CREATE INDEX idx_clients_actif ON clients(actif)');

    // Table: points_fidelite
    await db.execute('''
      CREATE TABLE points_fidelite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        points INTEGER NOT NULL,
        vente_id INTEGER,
        motif TEXT,
        solde_avant INTEGER NOT NULL,
        solde_apres INTEGER NOT NULL,
        date_transaction DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_expiration DATE,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY (vente_id) REFERENCES ventes(id),
        CHECK (type IN ('gain', 'utilisation', 'expiration', 'ajustement'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_points_client ON points_fidelite(client_id)',
    );
    await db.execute(
      'CREATE INDEX idx_points_date ON points_fidelite(date_transaction)',
    );

    // ==================== MODULE FOURNISSEURS ====================

    // Table: fournisseurs
    await db.execute('''
      CREATE TABLE fournisseurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_fournisseur TEXT UNIQUE,
        nom TEXT NOT NULL,
        contact_nom TEXT,
        telephone TEXT,
        telephone_2 TEXT,
        email TEXT,
        site_web TEXT,
        adresse TEXT,
        ville TEXT,
        code_postal TEXT,
        pays TEXT DEFAULT 'Algérie',
        registre_commerce TEXT,
        nif TEXT,
        nis TEXT,
        conditions_paiement TEXT,
        delai_livraison_jours INTEGER DEFAULT 7,
        montant_minimum_commande REAL DEFAULT 0,
        total_achats REAL DEFAULT 0,
        nombre_commandes INTEGER DEFAULT 0,
        date_derniere_commande DATETIME,
        actif INTEGER DEFAULT 1,
        note_evaluation INTEGER,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        CHECK (note_evaluation IS NULL OR (note_evaluation >= 1 AND note_evaluation <= 5))
      )
    ''');

    await db.execute('CREATE INDEX idx_fournisseurs_nom ON fournisseurs(nom)');
    await db.execute(
      'CREATE INDEX idx_fournisseurs_actif ON fournisseurs(actif)',
    );

    // Table: commandes_fournisseurs
    await db.execute('''
      CREATE TABLE commandes_fournisseurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_commande TEXT UNIQUE NOT NULL,
        fournisseur_id INTEGER NOT NULL,
        date_commande DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_livraison_prevue DATE,
        date_livraison_effective DATE,
        montant_ht REAL DEFAULT 0,
        montant_tva REAL DEFAULT 0,
        montant_ttc REAL DEFAULT 0,
        statut TEXT DEFAULT 'en_attente',
        utilisateur_id INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
        CHECK (statut IN ('en_attente', 'validee', 'expediee', 'recue', 'annulee'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_commandes_fournisseur ON commandes_fournisseurs(fournisseur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_commandes_date ON commandes_fournisseurs(date_commande)',
    );
    await db.execute(
      'CREATE INDEX idx_commandes_statut ON commandes_fournisseurs(statut)',
    );

    // Table: lignes_commande_fournisseur
    await db.execute('''
      CREATE TABLE lignes_commande_fournisseur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        quantite REAL NOT NULL,
        prix_unitaire_ht REAL NOT NULL,
        tva_taux REAL NOT NULL,
        total_ht REAL NOT NULL,
        total_ttc REAL NOT NULL,
        quantite_recue REAL DEFAULT 0,
        FOREIGN KEY (commande_id) REFERENCES commandes_fournisseurs(id) ON DELETE CASCADE,
        FOREIGN KEY (produit_id) REFERENCES produits(id),
        CHECK (quantite > 0),
        CHECK (quantite_recue >= 0)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_lignes_commande_fournisseur ON lignes_commande_fournisseur(commande_id)',
    );

    // ==================== MODULE SYSTÈME ====================

    // Table: utilisateurs
    await db.execute('''
      CREATE TABLE utilisateurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT,
        code_pin TEXT NOT NULL,
        telephone TEXT,
        email TEXT,
        role TEXT NOT NULL DEFAULT '${AppConstants.roleCaissier}',
        actif INTEGER DEFAULT 1,
        derniere_connexion DATETIME,
        nombre_connexions INTEGER DEFAULT 0,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
        photo_path TEXT,
        CHECK (role IN ('${AppConstants.roleAdmin}', '${AppConstants.roleGerant}', '${AppConstants.roleCaissier}', '${AppConstants.roleStockiste}')),
        UNIQUE(code_pin)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_utilisateurs_role ON utilisateurs(role)',
    );
    await db.execute(
      'CREATE INDEX idx_utilisateurs_actif ON utilisateurs(actif)',
    );

    // Table: permissions
    await db.execute('''
      CREATE TABLE permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        module TEXT NOT NULL,
        action TEXT NOT NULL,
        autorise INTEGER DEFAULT 1,
        UNIQUE(role, module, action),
        CHECK (role IN ('${AppConstants.roleAdmin}', '${AppConstants.roleGerant}', '${AppConstants.roleCaissier}', '${AppConstants.roleStockiste}')),
        CHECK (action IN ('lecture', 'creation', 'modification', 'suppression'))
      )
    ''');

    // Table: configuration
    await db.execute('''
      CREATE TABLE configuration (
        cle TEXT PRIMARY KEY,
        valeur TEXT,
        type TEXT DEFAULT 'string',
        categorie TEXT,
        description TEXT,
        date_modification DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: logs
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER,
        module TEXT NOT NULL,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        entite_type TEXT,
        entite_id INTEGER,
        valeurs_avant TEXT,
        valeurs_apres TEXT,
        adresse_ip TEXT,
        date_log DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_logs_utilisateur ON logs(utilisateur_id)',
    );
    await db.execute('CREATE INDEX idx_logs_date ON logs(date_log)');
    await db.execute('CREATE INDEX idx_logs_module ON logs(module)');
    await db.execute('CREATE INDEX idx_logs_action ON logs(action)');

    // Créer les triggers
    await _createTriggers(db);

    // Insérer les données initiales
    await _insertInitialData(db);

    print('✅ Base de données créée avec succès !');
  }

  /// Créer les triggers de la base de données
  Future<void> _createTriggers(Database db) async {
    print('🔧 Création des triggers...');

    // Trigger: Mise à jour automatique du stock après vente
    await db.execute('''
      CREATE TRIGGER after_vente_insert
      AFTER INSERT ON lignes_vente
      BEGIN
        UPDATE produits
        SET stock = stock - NEW.quantite
        WHERE id = NEW.produit_id;
        
        UPDATE produits
        SET en_rupture = 1
        WHERE id = NEW.produit_id AND stock <= 0;
        
        INSERT INTO mouvements_stock (
          produit_id, type, quantite, stock_avant, stock_apres,
          motif, vente_id, date_mouvement
        )
        SELECT
          NEW.produit_id,
          'vente',
          -NEW.quantite,
          stock + NEW.quantite,
          stock,
          'Vente N°' || (SELECT numero_facture FROM ventes WHERE id = NEW.vente_id),
          NEW.vente_id,
          CURRENT_TIMESTAMP
        FROM produits
        WHERE id = NEW.produit_id;
      END;
    ''');

    // Trigger: Mise à jour date_modification des produits
    await db.execute('''
      CREATE TRIGGER update_produit_timestamp
      AFTER UPDATE ON produits
      BEGIN
        UPDATE produits
        SET date_modification = CURRENT_TIMESTAMP
        WHERE id = NEW.id;
      END;
    ''');

    // Trigger: Calcul automatique du panier moyen client
    await db.execute('''
      CREATE TRIGGER update_client_stats
      AFTER INSERT ON ventes
      WHEN NEW.client_id IS NOT NULL AND NEW.statut = '${AppConstants.venteTerminee}'
      BEGIN
        UPDATE clients
        SET
          total_achats = total_achats + NEW.montant_ttc,
          nombre_achats = nombre_achats + 1,
          panier_moyen = (total_achats + NEW.montant_ttc) / (nombre_achats + 1),
          date_dernier_achat = NEW.date_vente
        WHERE id = NEW.client_id;
      END;
    ''');

    // Trigger: Mise à jour date_modification des clients
    await db.execute('''
      CREATE TRIGGER update_client_timestamp
      AFTER UPDATE ON clients
      BEGIN
        UPDATE clients
        SET date_modification = CURRENT_TIMESTAMP
        WHERE id = NEW.id;
      END;
    ''');

    print('✅ Triggers créés avec succès !');
  }

  /// Insérer les données initiales
  Future<void> _insertInitialData(Database db) async {
    print('📝 Insertion des données initiales...');

    // Utilisateur admin par défaut
    await db.insert('utilisateurs', {
      'nom': 'Administrateur',
      'prenom': 'Système',
      'code_pin': AppConstants.adminPINHash, // 1234 hashé
      'role': AppConstants.roleAdmin,
    });

    // Catégories par défaut
    final categories = [
      {
        'nom': 'Alimentation',
        'couleur': '#4CAF50',
        'icone': 'restaurant',
        'ordre': 1,
      },
      {
        'nom': 'Boissons',
        'couleur': '#2196F3',
        'icone': 'local_drink',
        'ordre': 2,
      },
      {
        'nom': 'Hygiène & Beauté',
        'couleur': '#E91E63',
        'icone': 'spa',
        'ordre': 3,
      },
      {
        'nom': 'Entretien',
        'couleur': '#9C27B0',
        'icone': 'cleaning_services',
        'ordre': 4,
      },
      {
        'nom': 'Électronique',
        'couleur': '#FF9800',
        'icone': 'devices',
        'ordre': 5,
      },
      {
        'nom': 'Vêtements',
        'couleur': '#00BCD4',
        'icone': 'checkroom',
        'ordre': 6,
      },
      {'nom': 'Maison', 'couleur': '#795548', 'icone': 'home', 'ordre': 7},
      {
        'nom': 'Divers',
        'couleur': '#9E9E9E',
        'icone': 'more_horiz',
        'ordre': 99,
      },
    ];

    for (var categorie in categories) {
      await db.insert('categories', categorie);
    }

    // Configuration par défaut
    final configs = [
      // Boutique
      {
        'cle': 'boutique_nom',
        'valeur': 'Ma Boutique',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Nom de la boutique',
      },
      {
        'cle': 'boutique_adresse',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Adresse complète',
      },
      {
        'cle': 'boutique_telephone',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Téléphone',
      },
      {
        'cle': 'boutique_email',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Email',
      },
      {
        'cle': 'boutique_siret',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Numéro SIRET/RC',
      },
      {
        'cle': 'boutique_nif',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'NIF',
      },
      {
        'cle': 'boutique_logo_path',
        'valeur': '',
        'type': 'string',
        'categorie': 'boutique',
        'description': 'Chemin du logo',
      },

      // Devise
      {
        'cle': 'devise_code',
        'valeur': AppConstants.deviseCode,
        'type': 'string',
        'categorie': 'devise',
        'description': 'Code devise',
      },
      {
        'cle': 'devise_symbole',
        'valeur': AppConstants.deviseSymbole,
        'type': 'string',
        'categorie': 'devise',
        'description': 'Symbole devise',
      },
      {
        'cle': 'devise_position',
        'valeur': 'apres',
        'type': 'string',
        'categorie': 'devise',
        'description': 'Position symbole',
      },
      {
        'cle': 'devise_decimales',
        'valeur': '${AppConstants.deviseDecimales}',
        'type': 'number',
        'categorie': 'devise',
        'description': 'Nombre de décimales',
      },

      // TVA
      {
        'cle': 'tva_taux_normal',
        'valeur': '${AppConstants.tauxTVANormal}',
        'type': 'number',
        'categorie': 'tva',
        'description': 'Taux TVA normal (%)',
      },
      {
        'cle': 'tva_taux_reduit',
        'valeur': '${AppConstants.tauxTVAReduit}',
        'type': 'number',
        'categorie': 'tva',
        'description': 'Taux TVA réduit (%)',
      },
      {
        'cle': 'tva_incluse',
        'valeur': '1',
        'type': 'boolean',
        'categorie': 'tva',
        'description': 'TVA incluse dans les prix',
      },

      // Impression
      {
        'cle': 'impression_ticket_largeur',
        'valeur': '${AppConstants.ticketWidth}',
        'type': 'number',
        'categorie': 'impression',
        'description': 'Largeur ticket (mm)',
      },
      {
        'cle': 'impression_logo_ticket',
        'valeur': '1',
        'type': 'boolean',
        'categorie': 'impression',
        'description': 'Afficher logo sur ticket',
      },
      {
        'cle': 'impression_auto',
        'valeur': '1',
        'type': 'boolean',
        'categorie': 'impression',
        'description': 'Impression automatique après vente',
      },
      {
        'cle': 'impression_nombre_copies',
        'valeur': '1',
        'type': 'number',
        'categorie': 'impression',
        'description': 'Nombre de copies',
      },

      // Fidélité
      {
        'cle': 'fidelite_active',
        'valeur': '1',
        'type': 'boolean',
        'categorie': 'fidelite',
        'description': 'Programme fidélité actif',
      },
      {
        'cle': 'fidelite_montant_1_point',
        'valeur': '${AppConstants.montantPour1Point}',
        'type': 'number',
        'categorie': 'fidelite',
        'description': 'Montant pour 1 point',
      },
      {
        'cle': 'fidelite_valeur_1_point',
        'valeur': '${AppConstants.valeur1Point}',
        'type': 'number',
        'categorie': 'fidelite',
        'description': 'Valeur d\'1 point',
      },

      // Système
      {
        'cle': 'version_app',
        'valeur': AppConstants.appVersion,
        'type': 'string',
        'categorie': 'systeme',
        'description': 'Version application',
      },
      {
        'cle': 'sauvegarde_auto',
        'valeur': '1',
        'type': 'boolean',
        'categorie': 'systeme',
        'description': 'Sauvegarde automatique',
      },
      {
        'cle': 'sauvegarde_frequence',
        'valeur': '7',
        'type': 'number',
        'categorie': 'systeme',
        'description': 'Fréquence sauvegarde (jours)',
      },
    ];

    for (var config in configs) {
      await db.insert('configuration', config);
    }

    // Permissions par défaut pour l'admin (accès total)
    final modules = [
      'vente',
      'produits',
      'stock',
      'clients',
      'rapports',
      'fournisseurs',
      'config',
    ];
    final actions = ['lecture', 'creation', 'modification', 'suppression'];

    for (var module in modules) {
      for (var action in actions) {
        await db.insert('permissions', {
          'role': AppConstants.roleAdmin,
          'module': module,
          'action': action,
          'autorise': 1,
        });
      }
    }

    print('✅ Données initiales insérées avec succès !');
  }

  /// Mise à niveau de la base de données
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print(
      '🔄 Mise à niveau de la base de données de v$oldVersion vers v$newVersion...',
    );

    // TODO: Gérer les migrations de schéma ici pour les futures versions

    print('✅ Mise à niveau terminée !');
  }

  /// Fermer la base de données
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    print('🔒 Base de données fermée');
  }

  /// Réinitialiser la base de données (ATTENTION: supprime toutes les données)
  Future<void> resetDatabase() async {
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final appPath = join(docsPath.path, AppConstants.appFolderName);
      final path = join(appPath, AppConstants.dbName);

      await close();

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Base de données supprimée');
      }

      _database = null;
      print('✅ Base de données réinitialisée');
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la réinitialisation de la base de données: $e',
      );
    }
  }
}
