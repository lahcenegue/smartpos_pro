import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente_provider.dart';
import '../../../repositories/vente_repository.dart';

/// Widget affichant les statistiques en temps réel
class StatsTempsReelWidget extends StatefulWidget {
  const StatsTempsReelWidget({super.key});

  @override
  State<StatsTempsReelWidget> createState() => _StatsTempsReelWidgetState();
}

class _StatsTempsReelWidgetState extends State<StatsTempsReelWidget> {
  final VenteRepository _venteRepo = VenteRepository();

  int _nombreVentes = 0;
  double _caJour = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerStats();

    // ← AJOUTER : Écouter les ventes finalisées via Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final venteProvider = context.read<VenteProvider>();
      venteProvider.onVenteFinalisee = () {
        if (mounted) {
          _chargerStats();
        }
      };
    });
  }

  Future<void> _chargerStats() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final debut = now.copyWith(hour: 0, minute: 0, second: 0);
      final fin = now.copyWith(hour: 23, minute: 59, second: 59);

      final ventes = await _venteRepo.getVentesParPeriode(debut, fin);

      final ventesTerminees =
          ventes.where((v) => v.statut == 'terminee').toList();

      final ca = ventesTerminees.fold<double>(
        0,
        (sum, vente) => sum + vente.montantTTC,
      );

      final nbVentes = ventesTerminees.length;

      if (mounted) {
        setState(() {
          _nombreVentes = nbVentes;
          _caJour = ca;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.primary),
          const SizedBox(width: AppStyles.paddingM),

          Expanded(
            child:
                _isLoading
                    ? const Text('Chargement...')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aujourd\'hui',
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_nombreVentes vente(s) • ${Formatters.formatDevise(_caJour)}',
                          style: AppStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),

          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Actualiser',
            onPressed: _chargerStats,
          ),
        ],
      ),
    );
  }
}
