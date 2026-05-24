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
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Color(0xFF8A53FF)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF8A53FF)),
            SizedBox(height: 16),
            Text("Menyiapkan Ruang Kerja Anda...",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
