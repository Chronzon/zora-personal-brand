import 'package:flutter/material.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/language_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/name_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Logic User Lama (Tetap sama)
      final hasData = await context.read<OnboardingProvider>().loadUserData();

      if (mounted) {
        await context.read<ContentCreationProvider>().loadScripts();
      }

      if (mounted) {
        if (hasData) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // Session ada tapi data korup/hilang -> Tetap ke NameScreen untuk isi data
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NameScreen()),
          );
        }
      }
    } else {
      // 2. UBAH BAGIAN INI: User Baru -> Arahkan ke WelcomeScreen
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
