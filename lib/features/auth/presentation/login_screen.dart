import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarl_mobile_app/features/auth/controllers/auth_controller.dart';
import 'package:tarl_mobile_app/l10n/app_localizations.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';
import 'package:tarl_mobile_app/app/theme/app_typography.dart';
import 'package:tarl_mobile_app/common/widgets/app_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _passwordVisible = false;
  bool _submitting = false;

  Future<void> _doLogin() async {
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).login(
      _username.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = ref.read(authControllerProvider);
      final navigator = Navigator.of(context);
      
      if (authState.mustChangePassword) {
        navigator.pushReplacementNamed('/change-password', arguments: authState.username);
      } else if (authState.isLoggedIn) {
        navigator.pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // TARL Logo and Branding
                _buildHeader(context, text),
                
                const SizedBox(height: 48),
                
                // Login Form
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(context, text, auth),
                ),
                
                const SizedBox(height: 32),
                
                // Footer
                _buildFooter(context, text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations text) {
    return Column(
      children: [
        // TARL Logo Placeholder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 64,
            color: AppColors.neutralWhite,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Welcome Text
        Text(
          'Welcome to TARL',
          style: AppTypography.displaySmall.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: AppTypography.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Parent Dashboard',
          style: AppTypography.titleLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Track your child\'s learning progress\nwith Teaching at the Right Level',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations text, AuthState auth) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            style: AppTypography.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.semiBold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Username Field
          TextFormField(
            controller: _username,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 20),
          
          // Password Field
          TextFormField(
            controller: _password,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _doLogin(),
          ),
          
          const SizedBox(height: 16),
          
          // Error Message
          if (auth.error != null && auth.error!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.statusError.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.statusError,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.statusError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Sign In Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _doLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.neutralWhite,
                elevation: 2,
                shadowColor: AppColors.primaryBlue.withOpacity(0.3),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.neutralWhite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations text) {
    return Column(
      children: [
        Text(
          'Powered by Teaching at the Right Level',
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 16,
              color: AppColors.statusSuccess,
            ),
            const SizedBox(width: 4),
            Text(
              'Secure & Private',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.statusSuccess,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
