/// Constants globales de l'application SmartPOS Pro
class AppConstants {
  // Informations application
  static const String appName = 'SmartPOS Pro';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'Votre Entreprise';

  // Base de données
  static const String dbName = 'smartpos_pro.db';
  static const int dbVersion = 1;
  static const String appFolderName = 'SmartPOS Pro';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String deviseSymbole = 'DA';
  static const String deviseCode = 'DZD';
  static const int deviseDecimales = 2;

  // TVA
  static const double tauxTVANormal = 19.0;
  static const double tauxTVAReduit = 9.0;

  // Stock
  static const int stockMinimumDefaut = 5;
  static const int stockMaximumDefaut = 1000;

  // Fidélité
  static const int montantPour1Point = 100; // 100 DA = 1 point
  static const double valeur1Point = 1.0; // 1 point = 1 DA

  // Codes PIN par défaut
  static const String adminPINHash =
      '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4'; // 1234

  // Modes de paiement
  static const String paiementEspeces = 'especes';
  static const String paiementCarte = 'carte';
  static const String paiementCheque = 'cheque';
  static const String paiementMixte = 'mixte';
  static const String paiementCredit = 'credit';

  // Statuts de vente
  static const String venteTerminee = 'terminee';
  static const String venteEnAttente = 'en_attente';
  static const String venteAnnulee = 'annulee';

  // Rôles utilisateurs
  static const String roleAdmin = 'admin';
  static const String roleGerant = 'gerant';
  static const String roleCaissier = 'caissier';
  static const String roleStockiste = 'stockiste';

  // Types de mouvement stock
  static const String mouvementEntree = 'entree';
  static const String mouvementSortie = 'sortie';
  static const String mouvementAjustement = 'ajustement';
  static const String mouvementVente = 'vente';
  static const String mouvementRetour = 'retour';
  static const String mouvementPerte = 'perte';

  // Types de clients
  static const String clientParticulier = 'particulier';
  static const String clientProfessionnel = 'professionnel';
  static const String clientVIP = 'vip';

  // Niveaux de fidélité
  static const String fideliteBronze = 'bronze';
  static const String fideliteArgent = 'argent';
  static const String fideliteOr = 'or';
  static const String fidelitePlatine = 'platine';

  // Messages
  static const String msgErreurGenerale = 'Une erreur est survenue';
  static const String msgSuccesEnregistrement = 'Enregistré avec succès';
  static const String msgSuccesModification = 'Modifié avec succès';
  static const String msgSuccesSuppression = 'Supprimé avec succès';
  static const String msgConfirmationSuppression =
      'Êtes-vous sûr de vouloir supprimer cet élément ?';

  // Dimensions
  static const double sidebarWidth = 250.0;
  static const double appBarHeight = 60.0;
  static const double bottomBarHeight = 80.0;

  // Impression
  static const int ticketWidth = 80; // mm
  static const String printerName = 'Default';
}
