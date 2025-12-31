import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utilitaires de formatage pour l'application
class Formatters {
  /// Formater un montant en devise
  /// Utilise les constantes AppConstants pour symbole et décimales
  ///
  /// Exemple: formatDevise(1250.50) => "1 250,50 DA"
  static String formatDevise(double montant, {bool afficherSymbole = true}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_DZ',
      symbol: afficherSymbole ? ' ${AppConstants.deviseSymbole}' : '',
      decimalDigits: AppConstants.deviseDecimales,
    );
    return formatter.format(montant);
  }

  /// Formater un nombre sans décimales
  ///
  /// Exemple: formatNombre(1250) => "1 250"
  static String formatNombre(int nombre) {
    final formatter = NumberFormat.decimalPattern('fr_DZ');
    return formatter.format(nombre);
  }

  /// Formater un nombre avec décimales
  /// Utilise le nombre de décimales par défaut de la devise
  ///
  /// Exemple: formatNombreDecimal(1250.456, 2) => "1 250,46"
  static String formatNombreDecimal(double nombre, {int? decimales}) {
    final dec = decimales ?? AppConstants.deviseDecimales;
    final formatter = NumberFormat('#,##0.${'0' * dec}', 'fr_DZ');
    return formatter.format(nombre);
  }

  /// Formater une date
  /// Utilise le format défini dans AppConstants
  ///
  /// Exemple: formatDate(DateTime.now()) => "31/12/2024"
  static String formatDate(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormat, 'fr_FR');
    return formatter.format(date);
  }

  /// Formater une date et heure
  /// Utilise le format défini dans AppConstants
  ///
  /// Exemple: formatDateTime(DateTime.now()) => "31/12/2024 14:30"
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat(AppConstants.dateTimeFormat, 'fr_FR');
    return formatter.format(dateTime);
  }

  /// Formater une heure
  /// Utilise le format défini dans AppConstants
  ///
  /// Exemple: formatTime(DateTime.now()) => "14:30"
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat, 'fr_FR');
    return formatter.format(time);
  }

  /// Formater un pourcentage
  ///
  /// Exemple: formatPourcentage(19.5) => "19,50 %"
  static String formatPourcentage(double pourcentage, {int? decimales}) {
    final dec = decimales ?? AppConstants.deviseDecimales;
    return '${formatNombreDecimal(pourcentage, decimales: dec)} %';
  }

  /// Formater un numéro de téléphone algérien
  ///
  /// Exemple: formatTelephone("0555123456") => "0555 12 34 56"
  static String formatTelephone(String telephone) {
    final cleaned = telephone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8)}';
    }

    return telephone;
  }

  /// Formater un code-barres
  ///
  /// Exemple: formatCodeBarre("1234567890123") => "123 456 789 0123"
  static String formatCodeBarre(String codeBarre) {
    if (codeBarre.length == 13) {
      // EAN-13
      return '${codeBarre.substring(0, 3)} ${codeBarre.substring(3, 6)} ${codeBarre.substring(6, 9)} ${codeBarre.substring(9)}';
    } else if (codeBarre.length == 8) {
      // EAN-8
      return '${codeBarre.substring(0, 4)} ${codeBarre.substring(4)}';
    }

    return codeBarre;
  }

  /// Formater une durée
  ///
  /// Exemple: formatDuree(Duration(hours: 2, minutes: 30)) => "2h 30min"
  static String formatDuree(Duration duree) {
    final heures = duree.inHours;
    final minutes = duree.inMinutes.remainder(60);

    if (heures > 0 && minutes > 0) {
      return '${heures}h ${minutes}min';
    } else if (heures > 0) {
      return '${heures}h';
    } else {
      return '${minutes}min';
    }
  }

  /// Formater une taille de fichier
  ///
  /// Exemple: formatTailleFichier(1536) => "1,50 Ko"
  static String formatTailleFichier(int octets) {
    const unites = ['o', 'Ko', 'Mo', 'Go'];
    int index = 0;
    double taille = octets.toDouble();

    while (taille >= 1024 && index < unites.length - 1) {
      taille /= 1024;
      index++;
    }

    return '${formatNombreDecimal(taille, decimales: 2)} ${unites[index]}';
  }

  /// Obtenir le nom du mois en français
  ///
  /// Exemple: getNomMois(12) => "Décembre"
  static String getNomMois(int mois) {
    const moisNoms = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    if (mois >= 1 && mois <= 12) {
      return moisNoms[mois - 1];
    }

    return '';
  }

  /// Obtenir le nom du jour en français
  ///
  /// Exemple: getNomJour(DateTime.monday) => "Lundi"
  static String getNomJour(int jour) {
    const jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    if (jour >= 1 && jour <= 7) {
      return jours[jour - 1];
    }

    return '';
  }

  /// Formater une date relative (il y a X jours, etc.)
  ///
  /// Exemple: formatDateRelative(DateTime.now().subtract(Duration(days: 2))) => "Il y a 2 jours"
  static String formatDateRelative(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final semaines = (difference.inDays / 7).floor();
      return 'Il y a $semaines semaine${semaines > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final mois = (difference.inDays / 30).floor();
      return 'Il y a $mois mois';
    } else {
      final annees = (difference.inDays / 365).floor();
      return 'Il y a $annees an${annees > 1 ? 's' : ''}';
    }
  }
}
