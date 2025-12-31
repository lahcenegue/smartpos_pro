import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

/// Barre de recherche pour les produits
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(String)? onScan;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.onScan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Champ de recherche
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher ou scanner un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            onSearch('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.paddingM,
                  vertical: AppStyles.paddingM,
                ),
              ),
              onChanged: (value) {
                // Recherche en temps réel après 300ms
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (controller.text == value) {
                    onSearch(value);
                  }
                });
              },
              onSubmitted: (value) {
                // Si c'est un code-barres (nombre), scanner
                if (onScan != null && RegExp(r'^\d+$').hasMatch(value)) {
                  onScan!(value);
                  controller.clear();
                } else {
                  onSearch(value);
                }
              },
            ),
          ),

          const SizedBox(width: AppStyles.paddingM),

          // Bouton scan
          if (onScan != null)
            ElevatedButton.icon(
              onPressed: () {
                // Focus sur le champ pour scanner
                FocusScope.of(context).requestFocus(FocusNode());
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vente,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.paddingL,
                  vertical: AppStyles.paddingM,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
