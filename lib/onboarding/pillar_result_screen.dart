import 'package:flutter/material.dart';
import 'package:personal_branding_app/screens/home_screen.dart'; // Impor home screen baru
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class PillarResultScreen extends StatelessWidget {
  const PillarResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Content Pillar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(provider.pillarAiResponse ?? 'Tidak ada hasil.'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: const Text('Go to Home'),
          onPressed: () {
            // Pindah ke Home Screen dan hapus semua rute sebelumnya
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}