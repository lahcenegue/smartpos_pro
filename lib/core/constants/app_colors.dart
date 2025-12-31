import 'package:flutter/material.dart';

/// Palette de couleurs de l'application SmartPOS Pro
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF2196F3); // Bleu
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  static const Color secondary = Color(0xFF4CAF50); // Vert
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);

  static const Color accent = Color(0xFFFF9800); // Orange

  // Couleurs système
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFEEEEEE);
  static const Color surface = Color(0xFFFFFFFF);

  // Couleurs de bordure
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Couleurs spécifiques aux modules
  static const Color vente = Color(0xFF2196F3); // Bleu
  static const Color produits = Color(0xFF9C27B0); // Violet
  static const Color stock = Color(0xFFFF9800); // Orange
  static const Color clients = Color(0xFF4CAF50); // Vert
  static const Color rapports = Color(0xFFE91E63); // Rose
  static const Color parametres = Color(0xFF607D8B); // Gris bleu

  // États de stock
  static const Color stockOk = Color(0xFF4CAF50);
  static const Color stockBas = Color(0xFFFF9800);
  static const Color stockRupture = Color(0xFFF44336);

  // Codes hex des couleurs de stock (pour usage dans helpers)
  static const String stockOkHex = '#4CAF50';
  static const String stockBasHex = '#FF9800';
  static const String stockRuptureHex = '#F44336';

  // Modes de paiement
  static const Color paiementEspeces = Color(0xFF4CAF50);
  static const Color paiementCarte = Color(0xFF2196F3);
  static const Color paiementCheque = Color(0xFFFF9800);
  static const Color paiementCredit = Color(0xFFF44336);

  // Overlay et ombres
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x1A000000);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Convertir une Color en string hex
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Convertir un string hex en Color
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
