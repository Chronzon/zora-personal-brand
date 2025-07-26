// lib/onboarding/swot_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/premise_result_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class SwotScreen extends StatefulWidget {
  const SwotScreen({super.key});

  @override
  State<SwotScreen> createState() => _SwotScreenState();
}

class _SwotScreenState extends State<SwotScreen> {
  final _formKey = GlobalKey<FormState>();

  void _generate() async {
    // Validasi dan simpan semua field yang ada
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Panggil fungsi generatePremise, yang akan otomatis menggunakan
      // nilai 'opportunities' yang sudah ada di provider.
      await Provider.of<OnboardingProvider>(context, listen: false).generatePremise();
      
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      if (provider.premiseAiResponse != null && provider.premiseOptions.isNotEmpty) {
         Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PremiseResultScreen(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? "Gagal memproses premis. Coba lagi."))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('PERSONAL DETECTOR INTELLIGENCE')),
      body: Consumer<OnboardingProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTextField(
                  label: 'Kekuatanmu',
                  hint: '(hal yang dikuasai & bisa dimanfaatkan)',
                  initialValue: provider.whatImGoodAt, // Pre-filled
                  onSaved: (val) => provider.strengths = val ?? '',
                ),
                _buildTextField(
                  label: 'Kelemahanmu',
                  hint: '(hambatan / keterbatasan pribadi)',
                  onSaved: (val) => provider.weaknesses = val ?? '',
                ),
                // FIELD PELUANGMU DIHILANGKAN DARI SINI
                _buildTextField(
                  label: 'Tantanganmu',
                  hint: '(hal yang menghambat keberhasilan)',
                  onSaved: (val) => provider.threats = val ?? '',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generate,
                  child: const Text('Next'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    String initialValue = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: 3,
        onSaved: onSaved,
        validator: (value) {
          // Hanya kekuatan yang boleh diisi otomatis dan tidak wajib diubah
          if (label != 'Kekuatanmu' && (value == null || value.isEmpty)) {
            return 'Field ini tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}
