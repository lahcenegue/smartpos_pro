import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';

/// Modèle pour les clients
class Client {
  final int? id;
  final String? codeClient;
  final String nom;
  final String? prenom;
  final String? entreprise;
  final String? telephone;
  final String? telephone2;
  final String? email;
  final String? adresse;
  final String? ville;
  final String? codePostal;
  final String pays;
  final String typeClient;
  final String niveauFidelite;
  final double credit;
  final double dette;
  final double plafondCredit;
  final int pointsFidelite;
  final double totalAchats;
  final int nombreAchats;
  final DateTime? dateDernierAchat;
  final double panierMoyen;
  final bool actif;
  final bool bloque;
  final bool accepteMarketing;
  final DateTime? dateNaissance;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final String? notes;

  Client({
    this.id,
    this.codeClient,
    required this.nom,
    this.prenom,
    this.entreprise,
    this.telephone,
    this.telephone2,
    this.email,
    this.adresse,
    this.ville,
    this.codePostal,
    this.pays = 'Algérie',
    this.typeClient = AppConstants.clientParticulier,
    this.niveauFidelite = AppConstants.fideliteBronze,
    this.credit = 0,
    this.dette = 0,
    this.plafondCredit = 0,
    this.pointsFidelite = 0,
    this.totalAchats = 0,
    this.nombreAchats = 0,
    this.dateDernierAchat,
    this.panierMoyen = 0,
    this.actif = true,
    this.bloque = false,
    this.accepteMarketing = false,
    this.dateNaissance,
    DateTime? dateCreation,
    this.dateModification,
    this.notes,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code_client': codeClient,
      'nom': nom,
      'prenom': prenom,
      'entreprise': entreprise,
      'telephone': telephone,
      'telephone_2': telephone2,
      'email': email,
      'adresse': adresse,
      'ville': ville,
      'code_postal': codePostal,
      'pays': pays,
      'type_client': typeClient,
      'niveau_fidelite': niveauFidelite,
      'credit': credit,
      'dette': dette,
      'plafond_credit': plafondCredit,
      'points_fidelite': pointsFidelite,
      'total_achats': totalAchats,
      'nombre_achats': nombreAchats,
      'date_dernier_achat': dateDernierAchat?.toIso8601String(),
      'panier_moyen': panierMoyen,
      'actif': actif ? 1 : 0,
      'bloque': bloque ? 1 : 0,
      'accepte_marketing': accepteMarketing ? 1 : 0,
      'date_naissance': dateNaissance?.toIso8601String(),
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      codeClient: map['code_client'],
      nom: map['nom'],
      prenom: map['prenom'],
      entreprise: map['entreprise'],
      telephone: map['telephone'],
      telephone2: map['telephone_2'],
      email: map['email'],
      adresse: map['adresse'],
      ville: map['ville'],
      codePostal: map['code_postal'],
      pays: map['pays'] ?? 'Algérie',
      typeClient: map['type_client'] ?? AppConstants.clientParticulier,
      niveauFidelite: map['niveau_fidelite'] ?? AppConstants.fideliteBronze,
      credit: map['credit']?.toDouble() ?? 0,
      dette: map['dette']?.toDouble() ?? 0,
      plafondCredit: map['plafond_credit']?.toDouble() ?? 0,
      pointsFidelite: map['points_fidelite'] ?? 0,
      totalAchats: map['total_achats']?.toDouble() ?? 0,
      nombreAchats: map['nombre_achats'] ?? 0,
      dateDernierAchat:
          map['date_dernier_achat'] != null
              ? DateTime.parse(map['date_dernier_achat'])
              : null,
      panierMoyen: map['panier_moyen']?.toDouble() ?? 0,
      actif: map['actif'] == 1,
      bloque: map['bloque'] == 1,
      accepteMarketing: map['accepte_marketing'] == 1,
      dateNaissance:
          map['date_naissance'] != null
              ? DateTime.parse(map['date_naissance'])
              : null,
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification:
          map['date_modification'] != null
              ? DateTime.parse(map['date_modification'])
              : null,
      notes: map['notes'],
    );
  }

  /// Getters calculés

  /// Nom complet du client
  String get nomComplet {
    if (entreprise != null && entreprise!.isNotEmpty) {
      return entreprise!;
    }
    return prenom != null ? '$prenom $nom' : nom;
  }

  /// Initiales du client
  String get initiales => Helpers.getInitiales(nom, prenom: prenom);

  /// Valeur en devise des points de fidélité
  double get valeurPoints => Helpers.calculerValeurPoints(pointsFidelite);

  /// Vérifier si le client a une dette
  bool get aDette => dette > 0;

  /// Vérifier si le client peut acheter à crédit
  bool get peutAcheterACredit => !bloque && dette < plafondCredit;

  /// Crédit disponible
  double get creditDisponible => plafondCredit - dette;

  /// CopyWith pour immutabilité
  Client copyWith({
    int? id,
    String? codeClient,
    String? nom,
    String? prenom,
    String? entreprise,
    String? telephone,
    String? telephone2,
    String? email,
    String? adresse,
    String? ville,
    String? codePostal,
    String? pays,
    String? typeClient,
    String? niveauFidelite,
    double? credit,
    double? dette,
    double? plafondCredit,
    int? pointsFidelite,
    double? totalAchats,
    int? nombreAchats,
    DateTime? dateDernierAchat,
    double? panierMoyen,
    bool? actif,
    bool? bloque,
    bool? accepteMarketing,
    DateTime? dateNaissance,
    DateTime? dateCreation,
    DateTime? dateModification,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      codeClient: codeClient ?? this.codeClient,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      entreprise: entreprise ?? this.entreprise,
      telephone: telephone ?? this.telephone,
      telephone2: telephone2 ?? this.telephone2,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      codePostal: codePostal ?? this.codePostal,
      pays: pays ?? this.pays,
      typeClient: typeClient ?? this.typeClient,
      niveauFidelite: niveauFidelite ?? this.niveauFidelite,
      credit: credit ?? this.credit,
      dette: dette ?? this.dette,
      plafondCredit: plafondCredit ?? this.plafondCredit,
      pointsFidelite: pointsFidelite ?? this.pointsFidelite,
      totalAchats: totalAchats ?? this.totalAchats,
      nombreAchats: nombreAchats ?? this.nombreAchats,
      dateDernierAchat: dateDernierAchat ?? this.dateDernierAchat,
      panierMoyen: panierMoyen ?? this.panierMoyen,
      actif: actif ?? this.actif,
      bloque: bloque ?? this.bloque,
      accepteMarketing: accepteMarketing ?? this.accepteMarketing,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, nom: $nomComplet, type: $typeClient)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
