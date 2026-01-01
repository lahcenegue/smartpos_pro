import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/vente/vente_providers.dart';

/// Widget affichant les statistiques en temps réel
class StatsTempsReelWidget extends ConsumerWidget {
  const StatsTempsReelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsJourProvider);

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
            child: statsAsync.when(
              data:
                  (stats) => Column(
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
                        '${stats['nombreVentes']} vente(s) • ${Formatters.formatDevise(stats['ca'])}',
                        style: AppStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              loading: () => const Text('Chargement...'),
              error:
                  (error, stack) =>
                      Text('Erreur', style: TextStyle(color: AppColors.error)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.invalidate(statsJourProvider);
            },
          ),
        ],
      ),
    );
  }
}
