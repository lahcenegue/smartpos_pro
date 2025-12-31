import '../constants/app_constants.dart';

/// Exceptions personnalisées pour SmartPOS Pro
///
/// Ces exceptions permettent de gérer les erreurs de manière typée
/// et de fournir des messages clairs à l'utilisateur

/// Exception de base pour toutes les exceptions métier
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception liée à la base de données
/// Renommée en AppDatabaseException pour éviter conflit avec sqflite
class AppDatabaseException extends AppException {
  AppDatabaseException(super.message, {super.code});
}

/// Exception d'authentification
class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

/// Exception de validation
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException(super.message, {this.errors, super.code});
}

/// Exception de stock insuffisant
class StockInsuffisantException extends AppException {
  final int stockDisponible;
  final int stockDemande;

  StockInsuffisantException({
    required this.stockDisponible,
    required this.stockDemande,
  }) : super(
         'Stock insuffisant. Disponible: $stockDisponible, Demandé: $stockDemande',
         code: 'STOCK_INSUFFISANT',
       );
}

/// Exception de produit introuvable
class ProduitIntrouvableException extends AppException {
  ProduitIntrouvableException(String identifiant)
    : super('Produit introuvable: $identifiant', code: 'PRODUIT_INTROUVABLE');
}

/// Exception d'impression
class PrintException extends AppException {
  PrintException(super.message, {super.code});
}

/// Exception de sauvegarde
class BackupException extends AppException {
  BackupException(super.message, {super.code});
}

/// Exception de permission
class PermissionException extends AppException {
  PermissionException(String action)
    : super(
        'Vous n\'avez pas la permission d\'effectuer cette action: $action',
        code: 'PERMISSION_DENIED',
      );
}

/// Exception de paiement
class PaiementException extends AppException {
  PaiementException(super.message, {super.code});
}

/// Exception de montant insuffisant
class MontantInsuffisantException extends AppException {
  final double montantDu;
  final double montantPaye;

  MontantInsuffisantException({
    required this.montantDu,
    required this.montantPaye,
  }) : super(
         'Montant insuffisant. Dû: ${montantDu.toStringAsFixed(AppConstants.deviseDecimales)} ${AppConstants.deviseSymbole}, Payé: ${montantPaye.toStringAsFixed(AppConstants.deviseDecimales)} ${AppConstants.deviseSymbole}',
         code: 'MONTANT_INSUFFISANT',
       );
}
