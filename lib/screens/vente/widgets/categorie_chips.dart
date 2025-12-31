import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/categorie.dart';
import '../../../repositories/produit_repository.dart';

/// Chips de filtrage par catégorie
class CategorieChips extends StatefulWidget {
  final int? categorieSelectionnee;
  final Function(int?) onCategorieSelected;

  const CategorieChips({
    super.key,
    required this.categorieSelectionnee,
    required this.onCategorieSelected,
  });

  @override
  State<CategorieChips> createState() => _CategorieChipsState();
}

class _CategorieChipsState extends State<CategorieChips> {
  final ProduitRepository _produitRepo = ProduitRepository();
  List<Categorie> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerCategories();
  }

  Future<void> _chargerCategories() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _produitRepo.getToutesCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
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
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingM,
        vertical: AppStyles.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Chip "Tout"
          Padding(
            padding: const EdgeInsets.only(right: AppStyles.paddingS),
            child: FilterChip(
              label: const Text('Tout'),
              selected: widget.categorieSelectionnee == null,
              onSelected: (selected) {
                if (selected) {
                  widget.onCategorieSelected(null);
                }
              },
              backgroundColor: AppColors.backgroundLight,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color:
                    widget.categorieSelectionnee == null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                fontWeight:
                    widget.categorieSelectionnee == null
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ),

          // Chips des catégories
          ..._categories.map((categorie) {
            final isSelected = widget.categorieSelectionnee == categorie.id;
            final couleur = AppColors.hexToColor(categorie.couleur);

            return Padding(
              padding: const EdgeInsets.only(right: AppStyles.paddingS),
              child: FilterChip(
                label: Text(categorie.nom),
                selected: isSelected,
                onSelected: (selected) {
                  widget.onCategorieSelected(selected ? categorie.id : null);
                },
                backgroundColor: AppColors.backgroundLight,
                selectedColor: couleur.withOpacity(0.2),
                checkmarkColor: couleur,
                labelStyle: TextStyle(
                  color: isSelected ? couleur : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
