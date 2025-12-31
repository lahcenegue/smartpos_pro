import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_routes.dart';
import '../core/services/auth_service.dart';
import '../core/utils/validators.dart';

/// Écran de connexion
///
/// Permet à l'utilisateur de se connecter avec son code PIN
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _authService = AuthService.instance;

  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  /// Tenter la connexion
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(_pinController.text);

      if (success && mounted) {
        // Navigation vers l'écran principal
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Afficher une erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.textLight,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Remplir rapidement le PIN (pour développement)
  void _fillDefaultPin() {
    _pinController.text = '1234';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.paddingL),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusL),
              ),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(AppStyles.paddingXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusL,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: AppStyles.paddingL),

                      // Titre
                      Text('Connexion', style: AppStyles.heading2),

                      const SizedBox(height: AppStyles.paddingS),

                      // Sous-titre
                      Text(
                        'Entrez votre code PIN pour accéder',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppStyles.paddingXL),

                      // Champ code PIN
                      TextFormField(
                        controller: _pinController,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Code PIN',
                          hintText: '••••',
                          prefixIcon: const Icon(Icons.pin),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePin
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscurePin = !_obscurePin);
                            },
                          ),
                          counterText: '',
                        ),
                        validator: Validators.validatePIN,
                        onFieldSubmitted: (_) => _login(),
                      ),

                      const SizedBox(height: AppStyles.paddingXL),

                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusM,
                              ),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textLight,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'Se connecter',
                                    style: AppStyles.labelLarge.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: AppStyles.paddingL),

                      // Bouton aide (développement)
                      TextButton.icon(
                        onPressed: _fillDefaultPin,
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('Utiliser PIN par défaut (1234)'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppStyles.paddingL),

                      // Info admin
                      Container(
                        padding: const EdgeInsets.all(AppStyles.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusM,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: AppStyles.paddingM),
                            Expanded(
                              child: Text(
                                'Utilisateur par défaut :\nAdmin (PIN: 1234)',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        color: AppColors.background,
        child: Text(
          '${AppConstants.appName} v${AppConstants.appVersion}',
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
