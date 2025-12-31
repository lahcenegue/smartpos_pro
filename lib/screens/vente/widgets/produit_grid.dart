import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/produit.dart';

/// Grille de produits
class ProduitGrid extends StatelessWidget {
  final List<Produit> produits;
  final Function(Produit) onProduitTap;

  const ProduitGrid({
    Key? key,
    required this.produits,
    required this.onProduitTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppStyles.paddingL),
            Text(
              'Aucun produit trouvé',
              style: AppStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppStyles.paddingM,
        mainAxisSpacing: AppStyles.paddingM,
        childAspectRatio: 0.85,
      ),
      itemCount: produits.length,
      itemBuilder: (context, index) {
        return _ProduitCard(
          produit: produits[index],
          onTap: () => onProduitTap(produits[index]),
        );
      },
    );
  }
}

/// Carte produit
class _ProduitCard extends StatelessWidget {
  final Produit produit;
  final VoidCallback onTap;

  const _ProduitCard({required this.produit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: InkWell(
        onTap: produit.disponible ? onTap : null,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image du produit
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppStyles.radiusM),
                        topRight: Radius.circular(AppStyles.radiusM),
                      ),
                    ),
                    child:
                        produit.imagePath != null
                            ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppStyles.radiusM),
                                topRight: Radius.circular(AppStyles.radiusM),
                              ),
                              child: Image.asset(
                                produit.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              ),
                            )
                            : _buildPlaceholder(),
                  ),
                ),

                // Informations du produit
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nom du produit
                        Text(
                          produit.nom,
                          style: AppStyles.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Prix et stock
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prix
                            Text(
                              Formatters.formatDevise(produit.prixEffectif),
                              style: AppStyles.prixMedium.copyWith(
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: AppStyles.paddingXS),

                            // Stock
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 14,
                                  color: _getStockColor(),
                                ),
                                const SizedBox(width: AppStyles.paddingXS),
                                Text(
                                  'Stock: ${produit.stock}',
                                  style: AppStyles.labelSmall.copyWith(
                                    color: _getStockColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Badge promotion
            if (produit.enPromotion)
              Positioned(
                top: AppStyles.paddingS,
                right: AppStyles.paddingS,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.paddingS,
                    vertical: AppStyles.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: Text(
                    'PROMO',
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Overlay rupture de stock
            if (!produit.disponible)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.overlay,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingM,
                        vertical: AppStyles.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      ),
                      child: Text(
                        'RUPTURE',
                        style: AppStyles.labelLarge.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }

  Color _getStockColor() {
    if (produit.enRupture) {
      return AppColors.stockRupture;
    } else if (produit.stockBas) {
      return AppColors.stockBas;
    } else {
      return AppColors.stockOk;
    }
  }
}
