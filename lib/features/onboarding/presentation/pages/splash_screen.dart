import 'package:flutter/material.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/language_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    final oauthError = _oauthCallbackValue('auth_error');
    final oauthToken = _oauthCallbackValue('auth_token');

    if (oauthError != null && oauthError.isNotEmpty) {
      authProvider.setExternalAuthError(oauthError);
    } else if (oauthToken != null && oauthToken.isNotEmpty) {
      await authProvider.completeOAuthSession(oauthToken);
    } else {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      await authProvider.restoreSession();
    }

    if (!mounted) return;

    final session = authProvider.currentUser;

    if (session != null && !session.isAnonymous) {
      await context.read<OnboardingProvider>().loadUserData();

      if (mounted) {
        await context.read<ContentCreationProvider>().loadScripts();
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        );
      }
    }
  }

  String? _oauthCallbackValue(String key) {
    final uri = Uri.base;
    final queryValue = uri.queryParameters[key];
    if (queryValue != null) return queryValue;

    final fragment = uri.fragment;
    if (fragment.isEmpty) return null;

    final queryStart = fragment.indexOf('?');
    if (queryStart == -1 || queryStart == fragment.length - 1) {
      return null;
    }

    final params = Uri.splitQueryString(fragment.substring(queryStart + 1));
    return params[key];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = constraints.maxWidth < 420 ? 132.0 : 156.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/zora_mark.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Color(0xFF8A53FF),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF8A53FF),
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Menyiapkan Ruang Kerja Anda...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
