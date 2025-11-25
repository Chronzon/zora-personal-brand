import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/pillar_result_screen.dart'; // Sesuaikan navigasi selanjutnya
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

// Widget chip kustom
class HoverAnimatedChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const HoverAnimatedChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<HoverAnimatedChip> createState() => _HoverAnimatedChipState();
}

class _HoverAnimatedChipState extends State<HoverAnimatedChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ChoiceChip(
          label: Text(widget.label),
          selected: widget.isSelected,
          onSelected: widget.onSelected,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          labelStyle: TextStyle(
            color: widget.isSelected ? purpleColor : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          selectedColor: Colors.grey.shade100,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: widget.isSelected ? purpleColor : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          showCheckmark: false,
        ),
      ),
    );
  }
}

class ToneOfVoiceScreen extends StatefulWidget {
  const ToneOfVoiceScreen({super.key});

  @override
  State<ToneOfVoiceScreen> createState() => _ToneOfVoiceScreenState();
}

class _ToneOfVoiceScreenState extends State<ToneOfVoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTone;
  final _toneOptions = [
    'Edukatif & Informatif', 'Casual & Friendly', 'Inspirational & Motivational',
    'Fun & Energetic', 'Luxury & Exclusive', 'Bold & Controversial', 'Visionary & Encouraging',
  ];
  final _targetAudienceController = TextEditingController();

  @override
  void dispose() {
    _targetAudienceController.dispose();
    super.dispose();
  }

  // FIXED: Logic _next diperbaiki dan dipisah dari build
  void _next() async {
    if (_formKey.currentState!.validate() && _selectedTone != null) {
      _formKey.currentState!.save();
      final provider = context.read<OnboardingProvider>();
      
      // Simpan data ke provider
      provider.toneOfVoice = _selectedTone;
      provider.targetAudience = _targetAudienceController.text;

      final languageCode = context.read<LocaleProvider>().languageCode;
      await provider.generateContentPillars(languageCode);

      if (!mounted) return;

      if (provider.pillarAiResponse != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PillarResultScreen(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? "Gagal generate strategi")),
        );
      }
    } else if (_selectedTone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Tone of Voice terlebih dahulu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);
    final provider = context.watch<OnboardingProvider>(); // Listen to provider changes

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'BrandBuilder AI'),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final padding = isMobile ? 24.0 : 48.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... Header Text ...
                       const Text(
                          'Langkah Terakhir, Tentukan Gaya Anda',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 48),
                      
                      // Tone of Voice Section
                      const Text('TONE OF VOICE', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16.0, runSpacing: 16.0,
                        children: _toneOptions.map((tone) {
                          return HoverAnimatedChip(
                            label: tone,
                            isSelected: _selectedTone == tone,
                            onSelected: (selected) => setState(() => _selectedTone = selected ? tone : null),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48),

                      // Target Audience Section
                      const Text('TARGET AUDIENCE', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _targetAudienceController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Mahasiswa, Profesional',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Tombol Continue
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Generate Strategy', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}