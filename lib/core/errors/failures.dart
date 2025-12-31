import 'package:equatable/equatable.dart';

/// Classe de base pour les échecs (failures)
///
/// Les Failures sont utilisés pour représenter des erreurs
/// de manière immutable et comparable
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Échec général
class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.code});
}

/// Échec de base de données
/// Renommé pour cohérence avec AppDatabaseException
class AppDatabaseFailure extends Failure {
  const AppDatabaseFailure(super.message, {super.code});
}

/// Échec d'authentification
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Échec de validation
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure(super.message, {this.errors, super.code});

  @override
  List<Object?> get props => [message, code, errors];
}

/// Échec de connexion réseau
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Échec de cache
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Échec d'impression
class PrintFailure extends Failure {
  const PrintFailure(super.message, {super.code});
}

/// Échec de sauvegarde
class BackupFailure extends Failure {
  const BackupFailure(super.message, {super.code});
}

/// Échec de permission
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}
