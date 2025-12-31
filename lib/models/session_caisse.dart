/// Modèle pour une session de caisse
class SessionCaisse {
  final int? id;
  final int utilisateurId;
  final DateTime dateOuverture;
  final double montantOuverture;
  final DateTime? dateFermeture;
  final double? montantFermeture;
  final double? montantTheorique;
  final double? ecart;
  final double totalEspeces;
  final double totalCarte;
  final double totalCheque;
  final int nombreVentes;
  final double montantTotalVentes;
  final String statut;
  final String? notesOuverture;
  final String? notesFermeture;

  SessionCaisse({
    this.id,
    required this.utilisateurId,
    DateTime? dateOuverture,
    this.montantOuverture = 0,
    this.dateFermeture,
    this.montantFermeture,
    this.montantTheorique,
    this.ecart,
    this.totalEspeces = 0,
    this.totalCarte = 0,
    this.totalCheque = 0,
    this.nombreVentes = 0,
    this.montantTotalVentes = 0,
    this.statut = 'ouverte',
    this.notesOuverture,
    this.notesFermeture,
  }) : dateOuverture = dateOuverture ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'date_ouverture': dateOuverture.toIso8601String(),
      'montant_ouverture': montantOuverture,
      'date_fermeture': dateFermeture?.toIso8601String(),
      'montant_fermeture': montantFermeture,
      'montant_theorique': montantTheorique,
      'ecart': ecart,
      'total_especes': totalEspeces,
      'total_carte': totalCarte,
      'total_cheque': totalCheque,
      'nombre_ventes': nombreVentes,
      'montant_total_ventes': montantTotalVentes,
      'statut': statut,
      'notes_ouverture': notesOuverture,
      'notes_fermeture': notesFermeture,
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory SessionCaisse.fromMap(Map<String, dynamic> map) {
    return SessionCaisse(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      dateOuverture: DateTime.parse(map['date_ouverture']),
      montantOuverture: map['montant_ouverture']?.toDouble() ?? 0,
      dateFermeture:
          map['date_fermeture'] != null
              ? DateTime.parse(map['date_fermeture'])
              : null,
      montantFermeture: map['montant_fermeture']?.toDouble(),
      montantTheorique: map['montant_theorique']?.toDouble(),
      ecart: map['ecart']?.toDouble(),
      totalEspeces: map['total_especes']?.toDouble() ?? 0,
      totalCarte: map['total_carte']?.toDouble() ?? 0,
      totalCheque: map['total_cheque']?.toDouble() ?? 0,
      nombreVentes: map['nombre_ventes'] ?? 0,
      montantTotalVentes: map['montant_total_ventes']?.toDouble() ?? 0,
      statut: map['statut'] ?? 'ouverte',
      notesOuverture: map['notes_ouverture'],
      notesFermeture: map['notes_fermeture'],
    );
  }

  /// Getters calculés

  /// Vérifier si la session est ouverte
  bool get estOuverte => statut == 'ouverte';

  /// Vérifier si la session est fermée
  bool get estFermee => statut == 'fermee';

  /// Durée de la session
  Duration get duree {
    if (dateFermeture != null) {
      return dateFermeture!.difference(dateOuverture);
    }
    return DateTime.now().difference(dateOuverture);
  }

  /// Total théorique attendu
  double get totalTheorique =>
      montantOuverture + totalEspeces + totalCarte + totalCheque;

  /// Vérifier s'il y a un écart
  bool get aEcart => ecart != null && ecart != 0;

  /// Panier moyen de la session
  double get panierMoyen {
    if (nombreVentes == 0) return 0;
    return montantTotalVentes / nombreVentes;
  }

  /// CopyWith pour immutabilité
  SessionCaisse copyWith({
    int? id,
    int? utilisateurId,
    DateTime? dateOuverture,
    double? montantOuverture,
    DateTime? dateFermeture,
    double? montantFermeture,
    double? montantTheorique,
    double? ecart,
    double? totalEspeces,
    double? totalCarte,
    double? totalCheque,
    int? nombreVentes,
    double? montantTotalVentes,
    String? statut,
    String? notesOuverture,
    String? notesFermeture,
  }) {
    return SessionCaisse(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      dateOuverture: dateOuverture ?? this.dateOuverture,
      montantOuverture: montantOuverture ?? this.montantOuverture,
      dateFermeture: dateFermeture ?? this.dateFermeture,
      montantFermeture: montantFermeture ?? this.montantFermeture,
      montantTheorique: montantTheorique ?? this.montantTheorique,
      ecart: ecart ?? this.ecart,
      totalEspeces: totalEspeces ?? this.totalEspeces,
      totalCarte: totalCarte ?? this.totalCarte,
      totalCheque: totalCheque ?? this.totalCheque,
      nombreVentes: nombreVentes ?? this.nombreVentes,
      montantTotalVentes: montantTotalVentes ?? this.montantTotalVentes,
      statut: statut ?? this.statut,
      notesOuverture: notesOuverture ?? this.notesOuverture,
      notesFermeture: notesFermeture ?? this.notesFermeture,
    );
  }

  @override
  String toString() {
    return 'SessionCaisse(id: $id, statut: $statut, ventes: $nombreVentes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionCaisse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
