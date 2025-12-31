import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../models/utilisateur.dart';
import '../../repositories/user_repository.dart';
import '../errors/exceptions.dart';
import '../constants/app_constants.dart';

/// Service d'authentification
///
/// Gère la connexion, déconnexion et la session utilisateur
class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final UserRepository _userRepo = UserRepository();
  Utilisateur? _currentUser;

  /// Utilisateur actuellement connecté
  Utilisateur? get currentUser => _currentUser;

  /// Vérifier si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  /// Vérifier si l'utilisateur est admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Vérifier si l'utilisateur est gérant
  bool get isGerant => _currentUser?.isGerant ?? false;

  /// Vérifier si l'utilisateur est caissier
  bool get isCaissier => _currentUser?.isCaissier ?? false;

  /// Vérifier si l'utilisateur est stockiste
  bool get isStockiste => _currentUser?.isStockiste ?? false;

  /// Connexion avec code PIN
  ///
  /// Retourne true si la connexion réussit, false sinon
  Future<bool> login(String codePIN) async {
    try {
      // Hasher le code PIN
      final hashedPIN = _hashPIN(codePIN);

      // Chercher l'utilisateur
      final user = await _userRepo.getUserByPIN(hashedPIN);

      if (user == null) {
        throw AuthException('Code PIN incorrect');
      }

      if (!user.actif) {
        throw AuthException('Compte désactivé. Contactez l\'administrateur.');
      }

      // Enregistrer l'utilisateur connecté
      _currentUser = user;

      // Mettre à jour la dernière connexion
      await _userRepo.mettreAJourDerniereConnexion(user.id!);

      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors de la connexion: $e');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _currentUser = null;
  }

  /// Changer le code PIN de l'utilisateur connecté
  Future<bool> changerCodePIN(String ancienPIN, String nouveauPIN) async {
    try {
      if (_currentUser == null) {
        throw AuthException('Aucun utilisateur connecté');
      }

      // Vérifier l'ancien PIN
      final hashedAncienPIN = _hashPIN(ancienPIN);
      if (hashedAncienPIN != _currentUser!.codePIN) {
        throw AuthException('Ancien code PIN incorrect');
      }

      // Hasher le nouveau PIN
      final hashedNouveauPIN = _hashPIN(nouveauPIN);

      // Mettre à jour en base
      await _userRepo.changerCodePIN(_currentUser!.id!, hashedNouveauPIN);

      // Mettre à jour l'utilisateur en mémoire
      _currentUser = _currentUser!.copyWith(codePIN: hashedNouveauPIN);

      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors du changement de code PIN: $e');
    }
  }

  /// Vérifier une permission
  ///
  /// Vérifie si l'utilisateur connecté a la permission d'effectuer une action
  /// sur un module donné
  bool hasPermission(String module, String action) {
    if (_currentUser == null) return false;

    // L'admin a toutes les permissions
    if (_currentUser!.isAdmin) return true;

    // TODO: Implémenter la vérification dans la table permissions
    // Pour l'instant, on applique des règles de base par rôle

    switch (_currentUser!.role) {
      case AppConstants.roleGerant:
        // Le gérant a toutes les permissions sauf suppression définitive
        return action != 'suppression_definitive';

      case AppConstants.roleCaissier:
        // Le caissier peut seulement faire des ventes et voir les produits/clients
        return (module == 'vente' && action == 'creation') ||
            (module == 'vente' && action == 'lecture') ||
            (module == 'produits' && action == 'lecture') ||
            (module == 'clients' && action == 'lecture');

      case AppConstants.roleStockiste:
        // Le stockiste gère les produits et le stock
        return (module == 'produits' && action != 'suppression') ||
            (module == 'stock');

      default:
        return false;
    }
  }

  /// Vérifier et lancer une exception si pas de permission
  void requirePermission(String module, String action) {
    if (!hasPermission(module, action)) {
      throw PermissionException('$module.$action');
    }
  }

  /// Hasher un code PIN avec SHA-256
  String _hashPIN(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Générer un hash pour un PIN donné (utilitaire)
  static String generatePINHash(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
