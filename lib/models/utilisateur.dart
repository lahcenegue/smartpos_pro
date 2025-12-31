import '../core/constants/app_constants.dart';

/// Modèle pour les utilisateurs du système
class Utilisateur {
  final int? id;
  final String nom;
  final String? prenom;
  final String codePIN;
  final String? telephone;
  final String? email;
  final String role;
  final bool actif;
  final DateTime? derniereConnexion;
  final int nombreConnexions;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final String? photoPath;

  Utilisateur({
    this.id,
    required this.nom,
    this.prenom,
    required this.codePIN,
    this.telephone,
    this.email,
    this.role = AppConstants.roleCaissier,
    this.actif = true,
    this.derniereConnexion,
    this.nombreConnexions = 0,
    DateTime? dateCreation,
    this.dateModification,
    this.photoPath,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'code_pin': codePIN,
      'telephone': telephone,
      'email': email,
      'role': role,
      'actif': actif ? 1 : 0,
      'derniere_connexion': derniereConnexion?.toIso8601String(),
      'nombre_connexions': nombreConnexions,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'photo_path': photoPath,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      codePIN: map['code_pin'],
      telephone: map['telephone'],
      email: map['email'],
      role: map['role'] ?? AppConstants.roleCaissier,
      actif: map['actif'] == 1,
      derniereConnexion:
          map['derniere_connexion'] != null
              ? DateTime.parse(map['derniere_connexion'])
              : null,
      nombreConnexions: map['nombre_connexions'] ?? 0,
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification:
          map['date_modification'] != null
              ? DateTime.parse(map['date_modification'])
              : null,
      photoPath: map['photo_path'],
    );
  }

  /// Getters calculés

  /// Nom complet de l'utilisateur
  String get nomComplet => prenom != null ? '$prenom $nom' : nom;

  /// Initiales de l'utilisateur
  String get initiales {
    String init = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    if (prenom != null && prenom!.isNotEmpty) {
      init += prenom![0].toUpperCase();
    }
    return init;
  }

  /// Vérifier si c'est un admin
  bool get isAdmin => role == AppConstants.roleAdmin;

  /// Vérifier si c'est un gérant
  bool get isGerant => role == AppConstants.roleGerant;

  /// Vérifier si c'est un caissier
  bool get isCaissier => role == AppConstants.roleCaissier;

  /// Vérifier si c'est un stockiste
  bool get isStockiste => role == AppConstants.roleStockiste;

  /// CopyWith pour immutabilité
  Utilisateur copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? codePIN,
    String? telephone,
    String? email,
    String? role,
    bool? actif,
    DateTime? derniereConnexion,
    int? nombreConnexions,
    DateTime? dateCreation,
    DateTime? dateModification,
    String? photoPath,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      codePIN: codePIN ?? this.codePIN,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      nombreConnexions: nombreConnexions ?? this.nombreConnexions,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  String toString() {
    return 'Utilisateur(id: $id, nom: $nomComplet, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Utilisateur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
