import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import '../../models/vente.dart';
import '../errors/exceptions.dart';

/// Service d'impression des tickets et factures
class PrintService {
  static final PrintService instance = PrintService._init();
  PrintService._init();

  /// Formater une date pour le PDF (sans dépendance locale)
  String _formatDatePDF(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Imprimer un ticket de vente
  Future<bool> imprimerTicket(Vente vente) async {
    try {
      // Générer le PDF du ticket
      final pdf = await _genererTicketPDF(vente);

      // Imprimer
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: vente.numeroFacture,
        format: PdfPageFormat.roll80, // Format thermique 80mm
      );

      return true;
    } catch (e) {
      throw PrintException('Erreur lors de l\'impression: $e');
    }
  }

  /// Imprimer une facture (avec détails TVA)
  Future<bool> imprimerFacture(Vente vente) async {
    try {
      // Générer le PDF de la facture
      final pdf = await _genererFacturePDF(vente);

      // Imprimer
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: vente.numeroFacture,
        format: PdfPageFormat.a4, // Format A4 pour factures
      );

      return true;
    } catch (e) {
      throw PrintException('Erreur lors de l\'impression: $e');
    }
  }

  /// Générer le PDF d'un ticket (80mm)
  Future<pw.Document> _genererTicketPDF(Vente vente) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Nom de la boutique
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      AppConstants.appName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Ticket de caisse',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Ligne de séparation
              pw.Divider(),

              // Informations du ticket
              _buildInfoRow('N° Ticket:', vente.numeroFacture),
              _buildInfoRow(
                'Date:',
                _formatDatePDF(vente.dateVente),
              ), // ← MODIFIÉ
              if (vente.clientId != null)
                _buildInfoRow('Client:', 'ID ${vente.clientId}'),

              pw.Divider(),
              pw.SizedBox(height: 8),

              // Articles
              pw.Text(
                'Articles',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Liste des articles
              ...vente.lignes.map((ligne) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              ligne.nomProduit,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            Formatters.formatDevise(ligne.totalTTC),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${ligne.quantite.toInt()} x ${Formatters.formatDevise(ligne.prixUnitaireTTC)}',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 8),
              pw.Divider(),

              // Total
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    Formatters.formatDevise(vente.montantTTC),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // Mode de paiement
              _buildInfoRow(
                'Mode paiement:',
                _getModePaiementLabel(vente.modePaiement),
              ),
              _buildInfoRow(
                'Payé:',
                Formatters.formatDevise(vente.montantPaye),
              ),

              if (vente.montantRendu > 0)
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'RENDU:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        Formatters.formatDevise(vente.montantRendu),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              pw.SizedBox(height: 16),
              pw.Divider(),

              // Footer
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Merci de votre visite !',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'À bientôt',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ),

              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Générer le PDF d'une facture (A4)
  Future<pw.Document> _genererFacturePDF(Vente vente) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppConstants.appName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Adresse de la boutique'),
                      pw.Text('Téléphone: 0555-XX-XX-XX'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FACTURE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('N°: ${vente.numeroFacture}'),
                      pw.Text(
                        'Date: ${_formatDatePDF(vente.dateVente)}',
                      ), // ← MODIFIÉ
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 32),

              // Client
              pw.Text(
                'CLIENT',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Client ID: ${vente.clientId}'),
                    // TODO: Ajouter les détails du client quand module disponible
                  ],
                ),
              ),

              pw.SizedBox(height: 32),

              // Tableau des articles
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Article', isHeader: true),
                      _buildTableCell('Qté', isHeader: true),
                      _buildTableCell('P.U. HT', isHeader: true),
                      _buildTableCell('TVA', isHeader: true),
                      _buildTableCell('Total TTC', isHeader: true),
                    ],
                  ),
                  // Lignes
                  ...vente.lignes.map((ligne) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(ligne.nomProduit),
                        _buildTableCell('${ligne.quantite.toInt()}'),
                        _buildTableCell(
                          Formatters.formatDevise(ligne.prixUnitaireHT),
                        ),
                        _buildTableCell('${ligne.tauxTVA}%'),
                        _buildTableCell(
                          Formatters.formatDevise(ligne.totalTTC),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 16),

              // Totaux
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Total HT:', vente.montantHT),
                        _buildTotalRow('TVA:', vente.montantTVA),
                        pw.Divider(),
                        _buildTotalRow(
                          'TOTAL TTC:',
                          vente.montantTTC,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Merci pour votre confiance',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Widget helper - Info row pour ticket
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  /// Widget helper - Cellule de tableau pour facture
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Widget helper - Ligne de total pour facture
  pw.Widget _buildTotalRow(
    String label,
    double montant, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            Formatters.formatDevise(montant),
            style: pw.TextStyle(
              fontSize: isBold ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtenir le libellé du mode de paiement
  String _getModePaiementLabel(String mode) {
    switch (mode) {
      case AppConstants.paiementEspeces:
        return 'Espèces';
      case AppConstants.paiementCarte:
        return 'Carte bancaire';
      case AppConstants.paiementCheque:
        return 'Chèque';
      case AppConstants.paiementMixte:
        return 'Paiement mixte';
      default:
        return mode;
    }
  }
}
