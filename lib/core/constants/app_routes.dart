/// Routes nommées de l'application
class AppRoutes {
  // Routes principales
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  // Module Vente
  static const String vente = '/vente';
  static const String venteEnAttente = '/vente/en-attente';
  static const String historiqueVentes = '/vente/historique';

  // Module Produits
  static const String produits = '/produits';
  static const String ajoutProduit = '/produits/ajout';
  static const String detailProduit = '/produits/detail';
  static const String categories = '/produits/categories';

  // Module Stock
  static const String stock = '/stock';
  static const String mouvementsStock = '/stock/mouvements';
  static const String inventaire = '/stock/inventaire';

  // Module Clients
  static const String clients = '/clients';
  static const String ajoutClient = '/clients/ajout';
  static const String ficheClient = '/clients/fiche';

  // Module Rapports
  static const String rapports = '/rapports';
  static const String dashboard = '/rapports/dashboard';
  static const String rapportVentes = '/rapports/ventes';
  static const String rapportStock = '/rapports/stock';
  static const String rapportCaisse = '/rapports/caisse';

  // Module Fournisseurs
  static const String fournisseurs = '/fournisseurs';
  static const String commandesFournisseurs = '/fournisseurs/commandes';

  // Module Paramètres
  static const String parametres = '/parametres';
  static const String utilisateurs = '/parametres/utilisateurs';
  static const String configBoutique = '/parametres/boutique';
  static const String sauvegarde = '/parametres/sauvegarde';
}
