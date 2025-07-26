import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/selection_screen.dart';
import 'package:personal_branding_app/onboarding/swot_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class AiResultScreen extends StatelessWidget {
  const AiResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis AI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(provider.aiResponse ?? 'Tidak ada hasil.'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: const Text('Next'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SelectionScreen(
                title: 'Pilih Nama Profil',
                options: provider.profileNameOptions,
                onSelect: (value) {
                  provider.selectedProfileName = value;
                },
                onNext: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SelectionScreen(
                      title: 'Pilih Kategori',
                      options: provider.categoryOptions,
                      onSelect: (value) {
                        provider.selectedCategory = value;
                      },
                      onNext: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SelectionScreen(
                            title: 'Pilih Micro-Niche',
                            options: provider.microNicheOptions,
                            onSelect: (value) {
                              provider.selectedMicroNiche = value;
                            },
                            onNext: () {
                              // Navigasi ke layar SWOT yang baru
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SwotScreen(),
                              ));
                            },
                          ),
                        ));
                      },
                    ),
                  ));
                },
              ),
            ));
          },
        ),
      ),
    );
  }
}
