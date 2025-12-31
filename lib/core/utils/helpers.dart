import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

/// Fonctions utilitaires diverses
class Helpers {
  /// Générer un code unique
  ///
  /// Exemple: generateCode('CLI') => "CLI-20241231-001"
  static String generateCode(String prefix) {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return '$prefix-$date-$random';
  }

  /// Générer un numéro de facture
  ///
  /// Exemple: generateNumeroFacture() => "FAC-20241231-0001"
  static String generateNumeroFacture() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'FAC-$date-$time';
  }

  /// Hasher un code PIN avec SHA-256
  static String hashPIN(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Calculer le montant HT depuis TTC
  static double calculerHT(double ttc, double tauxTVA) {
    return ttc / (1 + tauxTVA / 100);
  }

  /// Calculer le montant TTC depuis HT
  static double calculerTTC(double ht, double tauxTVA) {
    return ht * (1 + tauxTVA / 100);
  }

  /// Calculer le montant de la TVA
  static double calculerTVA(double ht, double tauxTVA) {
    return ht * (tauxTVA / 100);
  }

  /// Calculer la marge en pourcentage
  static double calculerMargePourcentage(double prixAchat, double prixVente) {
    if (prixAchat <= 0) return 0;
    return ((prixVente - prixAchat) / prixAchat) * 100;
  }

  /// Calculer le prix de vente avec marge
  static double calculerPrixVenteAvecMarge(
    double prixAchat,
    double margePourcentage,
  ) {
    return prixAchat * (1 + margePourcentage / 100);
  }

  /// Arrondir un montant selon les décimales de la devise
  static double arrondir(double montant, {int? decimales}) {
    final dec = decimales ?? AppConstants.deviseDecimales;
    final multiplicateur = pow(10, dec);
    return (montant * multiplicateur).round() / multiplicateur;
  }

  /// Générer un code-barres EAN-13
  static String generateEAN13() {
    final random = Random();
    String code = '';

    // Générer 12 chiffres aléatoires
    for (int i = 0; i < 12; i++) {
      code += random.nextInt(10).toString();
    }

    // Calculer la clé de contrôle
    int somme = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(code[i]);
      somme += (i % 2 == 0) ? digit : digit * 3;
    }

    int cle = (10 - (somme % 10)) % 10;
    code += cle.toString();

    return code;
  }

  /// Valider un code-barres EAN-13
  static bool validateEAN13(String code) {
    if (code.length != 13 || !RegExp(r'^\d{13}$').hasMatch(code)) {
      return false;
    }

    int somme = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(code[i]);
      somme += (i % 2 == 0) ? digit : digit * 3;
    }

    int cleCalculee = (10 - (somme % 10)) % 10;
    int cleFournie = int.parse(code[12]);

    return cleCalculee == cleFournie;
  }

  /// Calculer les points de fidélité gagnés
  static int calculerPointsFidelite(double montant) {
    return (montant / AppConstants.montantPour1Point).floor();
  }

  /// Calculer la valeur des points en devise
  static double calculerValeurPoints(int points) {
    return points * AppConstants.valeur1Point;
  }

  /// Vérifier si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifier si une date est dans la semaine en cours
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Vérifier si une date est dans le mois en cours
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Obtenir le premier jour du mois
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Obtenir le dernier jour du mois
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Obtenir la couleur selon le niveau de stock (en hex)
  /// Utilise les constantes définies dans AppColors
  static String getStockColorHex(int stock, int stockMinimum) {
    if (stock <= 0) {
      return AppColors.stockRuptureHex;
    } else if (stock <= stockMinimum) {
      return AppColors.stockBasHex;
    } else {
      return AppColors.stockOkHex;
    }
  }

  /// Obtenir la couleur selon le niveau de stock (Color)
  /// Utilise les constantes définies dans AppColors
  static Color getStockColor(int stock, int stockMinimum) {
    if (stock <= 0) {
      return AppColors.stockRupture;
    } else if (stock <= stockMinimum) {
      return AppColors.stockBas;
    } else {
      return AppColors.stockOk;
    }
  }

  /// Nettoyer un numéro de téléphone
  static String cleanTelephone(String telephone) {
    return telephone.replaceAll(RegExp(r'\D'), '');
  }

  /// Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Tronquer un texte
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Obtenir les initiales d'un nom
  static String getInitiales(String nom, {String? prenom}) {
    String initiales = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    if (prenom != null && prenom.isNotEmpty) {
      initiales += prenom[0].toUpperCase();
    }
    return initiales;
  }

  /// Convertir bytes en taille lisible
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
