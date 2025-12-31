import '../constants/app_constants.dart';

/// Validateurs pour les formulaires
class Validators {
  /// Valider si un champ est vide
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est obligatoire';
    }
    return null;
  }

  /// Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est obligatoire';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  /// Valider un numéro de téléphone algérien
  static String? validateTelephone(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le numéro de téléphone est obligatoire' : null;
    }

    // Nettoyer le numéro
    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    // Vérifier longueur (10 chiffres pour l'Algérie)
    if (cleaned.length != 10) {
      return 'Le numéro doit contenir 10 chiffres';
    }

    // Vérifier préfixe (05, 06, 07)
    if (!cleaned.startsWith('05') &&
        !cleaned.startsWith('06') &&
        !cleaned.startsWith('07')) {
      return 'Le numéro doit commencer par 05, 06 ou 07';
    }

    return null;
  }

  /// Valider un montant
  static String? validateMontant(
    String? value, {
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Le montant est obligatoire' : null;
    }

    final montant = double.tryParse(value.replaceAll(',', '.'));

    if (montant == null) {
      return 'Montant invalide';
    }

    if (min != null && montant < min) {
      return 'Le montant doit être au moins ${min.toStringAsFixed(AppConstants.deviseDecimales)} ${AppConstants.deviseSymbole}';
    }

    if (max != null && montant > max) {
      return 'Le montant ne peut pas dépasser ${max.toStringAsFixed(AppConstants.deviseDecimales)} ${AppConstants.deviseSymbole}';
    }

    if (montant < 0) {
      return 'Le montant ne peut pas être négatif';
    }

    return null;
  }

  /// Valider une quantité
  static String? validateQuantite(
    String? value, {
    int? min,
    int? max,
    int? stockDisponible,
  }) {
    if (value == null || value.isEmpty) {
      return 'La quantité est obligatoire';
    }

    final quantite = int.tryParse(value);

    if (quantite == null) {
      return 'Quantité invalide';
    }

    if (quantite <= 0) {
      return 'La quantité doit être supérieure à 0';
    }

    if (min != null && quantite < min) {
      return 'La quantité minimum est $min';
    }

    if (max != null && quantite > max) {
      return 'La quantité maximum est $max';
    }

    if (stockDisponible != null && quantite > stockDisponible) {
      return 'Stock insuffisant (disponible: $stockDisponible)';
    }

    return null;
  }

  /// Valider un code PIN (4 chiffres)
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est obligatoire';
    }

    if (value.length != 4) {
      return 'Le code PIN doit contenir 4 chiffres';
    }

    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'Le code PIN doit contenir uniquement des chiffres';
    }

    return null;
  }

  /// Valider un code-barres
  static String? validateCodeBarre(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le code-barres est obligatoire' : null;
    }

    // Accepter EAN-13 (13 chiffres) ou EAN-8 (8 chiffres)
    if (!RegExp(r'^\d{8}$').hasMatch(value) &&
        !RegExp(r'^\d{13}$').hasMatch(value)) {
      return 'Code-barres invalide (8 ou 13 chiffres)';
    }

    return null;
  }

  /// Valider un pourcentage
  static String? validatePourcentage(
    String? value, {
    double min = 0,
    double max = 100,
  }) {
    if (value == null || value.isEmpty) {
      return 'Le pourcentage est obligatoire';
    }

    final pourcentage = double.tryParse(value.replaceAll(',', '.'));

    if (pourcentage == null) {
      return 'Pourcentage invalide';
    }

    if (pourcentage < min || pourcentage > max) {
      return 'Le pourcentage doit être entre $min et $max';
    }

    return null;
  }

  /// Valider une longueur de texte
  static String? validateLength(
    String? value, {
    int? min,
    int? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Utiliser validateRequired séparément
    }

    if (min != null && value.length < min) {
      return '${fieldName ?? 'Ce champ'} doit contenir au moins $min caractères';
    }

    if (max != null && value.length > max) {
      return '${fieldName ?? 'Ce champ'} ne peut pas dépasser $max caractères';
    }

    return null;
  }

  /// Valider un NIF (Numéro d'Identification Fiscale algérien)
  static String? validateNIF(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le NIF est obligatoire' : null;
    }

    // NIF algérien : 15 chiffres
    if (!RegExp(r'^\d{15}$').hasMatch(value)) {
      return 'NIF invalide (15 chiffres requis)';
    }

    return null;
  }

  /// Valider un NIS (Numéro d'Identification Statistique algérien)
  static String? validateNIS(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le NIS est obligatoire' : null;
    }

    // NIS algérien : 20 chiffres
    if (!RegExp(r'^\d{20}$').hasMatch(value)) {
      return 'NIS invalide (20 chiffres requis)';
    }

    return null;
  }

  /// Valider un mot de passe
  static String? validatePassword(
    String? value, {
    int minLength = 6,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    if (requireSpecialChars &&
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
  }
}
