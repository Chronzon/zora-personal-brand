import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/pillar_result_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class ToneOfVoiceScreen extends StatefulWidget {
  const ToneOfVoiceScreen({super.key});

  @override
  State<ToneOfVoiceScreen> createState() => _ToneOfVoiceScreenState();
}

class _ToneOfVoiceScreenState extends State<ToneOfVoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTone;
  final _toneOptions = [
    'Edukatif & Informatif',
    'Casual & Friendly',
    'Inspirational & Motivational',
    'Fun & Energetic',
    'Luxury & Exclusive',
    'Bold & Controversial',
    'Visionary & Encouraging',
  ];

  void _next() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<OnboardingProvider>();
      provider.toneOfVoice = _selectedTone;

      await provider.generateContentPillars();

      if (provider.pillarAiResponse != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PillarResultScreen(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Gagal generate pillar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Langkah Terakhir')),
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTone,
                  items: _toneOptions.map((tone) {
                    return DropdownMenuItem(value: tone, child: Text(tone));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTone = value),
                  decoration: const InputDecoration(
                    labelText: 'TONE OF VOICE',
                    helperText: '(gaya bicara yang ingin dibawakan)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? 'Pilih tone of voice' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'TARGET AUDIENS',
                    helperText: '(ingin membuat konten untuk siapa?)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => provider.targetAudience = value ?? '',
                  validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _next, child: const Text('Next')),
              ],
            ),
          );
        },
      ),
    );
  }
}