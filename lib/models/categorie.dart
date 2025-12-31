/// Modèle pour les catégories de produits
class Categorie {
  final int? id;
  final String nom;
  final int? parentId;
  final String couleur;
  final String icone;
  final int ordre;
  final String? description;
  final bool actif;
  final DateTime dateCreation;

  Categorie({
    this.id,
    required this.nom,
    this.parentId,
    this.couleur = '#2196F3',
    this.icone = 'category',
    this.ordre = 0,
    this.description,
    this.actif = true,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'parent_id': parentId,
      'couleur': couleur,
      'icone': icone,
      'ordre': ordre,
      'description': description,
      'actif': actif ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  /// Création depuis Map (depuis SQLite)
  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'],
      nom: map['nom'],
      parentId: map['parent_id'],
      couleur: map['couleur'] ?? '#2196F3',
      icone: map['icone'] ?? 'category',
      ordre: map['ordre'] ?? 0,
      description: map['description'],
      actif: map['actif'] == 1,
      dateCreation: DateTime.parse(map['date_creation']),
    );
  }

  /// CopyWith pour immutabilité
  Categorie copyWith({
    int? id,
    String? nom,
    int? parentId,
    String? couleur,
    String? icone,
    int? ordre,
    String? description,
    bool? actif,
    DateTime? dateCreation,
  }) {
    return Categorie(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      parentId: parentId ?? this.parentId,
      couleur: couleur ?? this.couleur,
      icone: icone ?? this.icone,
      ordre: ordre ?? this.ordre,
      description: description ?? this.description,
      actif: actif ?? this.actif,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'Categorie(id: $id, nom: $nom, ordre: $ordre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categorie && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
