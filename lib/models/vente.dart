import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import 'ligne_vente.dart';

/// Modèle pour une vente complète
class Vente {
  final int? id;
  final String numeroFacture;
  final String? numeroTicket;
  final int? clientId;
  final int utilisateurId;
  final int? sessionCaisseId;
  final double montantHT;
  final double montantTVA;
  final double montantTTC;
  final double montantRemise;
  final double remisePourcentage;
  final String modePaiement;
  final double montantEspeces;
  final double montantCarte;
  final double montantCheque;
  final double montantCredit;
  final double montantPaye;
  final double montantRendu;
  final int pointsUtilises;
  final int pointsGagnes;
  final String statut;
  final String? motifAnnulation;
  final DateTime dateVente;
  final DateTime? dateAnnulation;
  final String? notes;
  final bool imprimee;
  final List<LigneVente> lignes;

  Vente({
    this.id,
    required this.numeroFacture,
    this.numeroTicket,
    this.clientId,
    required this.utilisateurId,
    this.sessionCaisseId,
    required this.montantHT,
    required this.montantTVA,
    required this.montantTTC,
    this.montantRemise = 0,
    this.remisePourcentage = 0,
    required this.modePaiement,
    this.montantEspeces = 0,
    this.montantCarte = 0,
    this.montantCheque = 0,
    this.montantCredit = 0,
    required this.montantPaye,
    this.montantRendu = 0,
    this.pointsUtilises = 0,
    this.pointsGagnes = 0,
    this.statut = AppConstants.venteTerminee,
    this.motifAnnulation,
    DateTime? dateVente,
    this.dateAnnulation,
    this.notes,
    this.imprimee = false,
    this.lignes = const [],
  }) : dateVente = dateVente ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_facture': numeroFacture,
      'numero_ticket': numeroTicket,
      'client_id': clientId,
      'utilisateur_id': utilisateurId,
      'session_caisse_id': sessionCaisseId,
      'montant_ht': montantHT,
      'montant_tva': montantTVA,
      'montant_ttc': montantTTC,
      'montant_remise': montantRemise,
      'remise_pourcentage': remisePourcentage,
      'mode_paiement': modePaiement,
      'montant_especes': montantEspeces,
      'montant_carte': montantCarte,
      'montant_cheque': montantCheque,
      'montant_credit': montantCredit,
      'montant_paye': montantPaye,
      'montant_rendu': montantRendu,
      'points_utilises': pointsUtilises,
      'points_gagnes': pointsGagnes,
      'statut': statut,
      'motif_annulation': motifAnnulation,
      'date_vente': dateVente.toIso8601String(),
      'date_annulation': dateAnnulation?.toIso8601String(),
      'notes': notes,
      'imprimee': imprimee ? 1 : 0,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory Vente.fromMap(Map<String, dynamic> map, {List<LigneVente>? lignes}) {
    return Vente(
      id: map['id'],
      numeroFacture: map['numero_facture'],
      numeroTicket: map['numero_ticket'],
      clientId: map['client_id'],
      utilisateurId: map['utilisateur_id'],
      sessionCaisseId: map['session_caisse_id'],
      montantHT: map['montant_ht']?.toDouble() ?? 0,
      montantTVA: map['montant_tva']?.toDouble() ?? 0,
      montantTTC: map['montant_ttc']?.toDouble() ?? 0,
      montantRemise: map['montant_remise']?.toDouble() ?? 0,
      remisePourcentage: map['remise_pourcentage']?.toDouble() ?? 0,
      modePaiement: map['mode_paiement'],
      montantEspeces: map['montant_especes']?.toDouble() ?? 0,
      montantCarte: map['montant_carte']?.toDouble() ?? 0,
      montantCheque: map['montant_cheque']?.toDouble() ?? 0,
      montantCredit: map['montant_credit']?.toDouble() ?? 0,
      montantPaye: map['montant_paye']?.toDouble() ?? 0,
      montantRendu: map['montant_rendu']?.toDouble() ?? 0,
      pointsUtilises: map['points_utilises'] ?? 0,
      pointsGagnes: map['points_gagnes'] ?? 0,
      statut: map['statut'] ?? AppConstants.venteTerminee,
      motifAnnulation: map['motif_annulation'],
      dateVente: DateTime.parse(map['date_vente']),
      dateAnnulation:
          map['date_annulation'] != null
              ? DateTime.parse(map['date_annulation'])
              : null,
      notes: map['notes'],
      imprimee: map['imprimee'] == 1,
      lignes: lignes ?? [],
    );
  }

  /// Constructeur factory pour créer une vente depuis des lignes
  factory Vente.fromLignes({
    required List<LigneVente> lignes,
    required int utilisateurId,
    required String modePaiement,
    required double montantPaye,
    int? clientId,
    int? sessionCaisseId,
    double remiseGlobale = 0,
    int pointsUtilises = 0,
  }) {
    // Calculer les totaux
    double totalHT = 0;
    double totalTVA = 0;
    double totalTTC = 0;

    for (var ligne in lignes) {
      totalHT += ligne.totalHT;
      totalTVA += ligne.totalTVA;
      totalTTC += ligne.totalTTC;
    }

    // Appliquer la remise globale
    double montantRemise = remiseGlobale;
    if (remiseGlobale > 0) {
      totalHT -= remiseGlobale;
      totalTTC = totalHT + totalTVA;
    }

    // Déduire la valeur des points utilisés
    double valeurPoints = Helpers.calculerValeurPoints(pointsUtilises);
    if (valeurPoints > 0) {
      totalTTC -= valeurPoints;
      totalTTC = totalTTC < 0 ? 0 : totalTTC; // Ne pas être négatif
    }

    // Arrondir les totaux
    totalHT = Helpers.arrondir(totalHT);
    totalTVA = Helpers.arrondir(totalTVA);
    totalTTC = Helpers.arrondir(totalTTC);

    // Calculer les points gagnés
    int pointsGagnes = Helpers.calculerPointsFidelite(totalTTC);

    // Calculer le rendu monnaie
    double montantRendu = montantPaye > totalTTC ? montantPaye - totalTTC : 0;

    // Générer le numéro de facture
    String numeroFacture = Helpers.generateNumeroFacture();

    return Vente(
      numeroFacture: numeroFacture,
      clientId: clientId,
      utilisateurId: utilisateurId,
      sessionCaisseId: sessionCaisseId,
      montantHT: totalHT,
      montantTVA: totalTVA,
      montantTTC: totalTTC,
      montantRemise: montantRemise,
      modePaiement: modePaiement,
      montantPaye: montantPaye,
      montantRendu: montantRendu,
      pointsUtilises: pointsUtilises,
      pointsGagnes: pointsGagnes,
      lignes: lignes,
    );
  }

  /// Getters calculés

  /// Nombre d'articles
  int get nombreArticles =>
      lignes.fold(0, (sum, ligne) => sum + ligne.quantite.toInt());

  /// Vérifier si c'est un paiement mixte
  bool get estPaiementMixte => modePaiement == AppConstants.paiementMixte;

  /// Vérifier si la vente est terminée
  bool get estTerminee => statut == AppConstants.venteTerminee;

  /// Vérifier si la vente est en attente
  bool get estEnAttente => statut == AppConstants.venteEnAttente;

  /// Vérifier si la vente est annulée
  bool get estAnnulee => statut == AppConstants.venteAnnulee;

  /// Vérifier si la vente a une remise
  bool get aRemise => montantRemise > 0 || remisePourcentage > 0;

  /// Vérifier si des points ont été utilisés
  bool get pointsUtilisesDansVente => pointsUtilises > 0;

  /// Vérifier si le client gagne des points
  bool get clientGagnePoints => pointsGagnes > 0;

  /// CopyWith pour immutabilité
  Vente copyWith({
    int? id,
    String? numeroFacture,
    String? numeroTicket,
    int? clientId,
    int? utilisateurId,
    int? sessionCaisseId,
    double? montantHT,
    double? montantTVA,
    double? montantTTC,
    double? montantRemise,
    double? remisePourcentage,
    String? modePaiement,
    double? montantEspeces,
    double? montantCarte,
    double? montantCheque,
    double? montantCredit,
    double? montantPaye,
    double? montantRendu,
    int? pointsUtilises,
    int? pointsGagnes,
    String? statut,
    String? motifAnnulation,
    DateTime? dateVente,
    DateTime? dateAnnulation,
    String? notes,
    bool? imprimee,
    List<LigneVente>? lignes,
  }) {
    return Vente(
      id: id ?? this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      numeroTicket: numeroTicket ?? this.numeroTicket,
      clientId: clientId ?? this.clientId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      sessionCaisseId: sessionCaisseId ?? this.sessionCaisseId,
      montantHT: montantHT ?? this.montantHT,
      montantTVA: montantTVA ?? this.montantTVA,
      montantTTC: montantTTC ?? this.montantTTC,
      montantRemise: montantRemise ?? this.montantRemise,
      remisePourcentage: remisePourcentage ?? this.remisePourcentage,
      modePaiement: modePaiement ?? this.modePaiement,
      montantEspeces: montantEspeces ?? this.montantEspeces,
      montantCarte: montantCarte ?? this.montantCarte,
      montantCheque: montantCheque ?? this.montantCheque,
      montantCredit: montantCredit ?? this.montantCredit,
      montantPaye: montantPaye ?? this.montantPaye,
      montantRendu: montantRendu ?? this.montantRendu,
      pointsUtilises: pointsUtilises ?? this.pointsUtilises,
      pointsGagnes: pointsGagnes ?? this.pointsGagnes,
      statut: statut ?? this.statut,
      motifAnnulation: motifAnnulation ?? this.motifAnnulation,
      dateVente: dateVente ?? this.dateVente,
      dateAnnulation: dateAnnulation ?? this.dateAnnulation,
      notes: notes ?? this.notes,
      imprimee: imprimee ?? this.imprimee,
      lignes: lignes ?? this.lignes,
    );
  }

  @override
  String toString() {
    return 'Vente(n°: $numeroFacture, montant: $montantTTC, articles: $nombreArticles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
