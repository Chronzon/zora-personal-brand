import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/selection_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class PremiseResultScreen extends StatelessWidget {
  const PremiseResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Premis dari AI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(provider.premiseAiResponse ?? 'Tidak ada hasil.'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: const Text('Next'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SelectionScreen(
                title: 'Pilih Premis Personal Branding',
                options: provider.premiseOptions,
                onSelect: (value) {
                  provider.selectedPremise = value;
                },
                onNext: () {
                  // TODO: Lanjutkan ke langkah berikutnya sesuai instruksi
                  print('Premis yang dipilih: ${provider.selectedPremise}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Langkah selanjutnya belum diimplementasikan.'))
                  );
                },
              ),
            ));
          },
        ),
      ),
    );
  }
}