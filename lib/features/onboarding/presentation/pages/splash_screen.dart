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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session = context.read<AuthProvider>().currentUser;

    if (session != null) {
      // Logic User Lama (Tetap sama)
      final hasData = await context.read<OnboardingProvider>().loadUserData();

      if (mounted) {
        await context.read<ContentCreationProvider>().loadScripts();
      }

      if (mounted) {
        if (hasData) {
          // 1. Data Lengkap -> Ke Dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // 2. Session Ada TAPI Data Belum Lengkap (User Gantung/Belum Selesai Onboarding)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LanguageScreen()),
          );
        }
      }
    } else {
      // 3. User Baru (Belum Login) -> Ke LanguageScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        );
      }
    }
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
