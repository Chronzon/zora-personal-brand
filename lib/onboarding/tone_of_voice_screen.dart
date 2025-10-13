import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/pillar_result_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:personal_branding_app/widgets/custom_app_bar.dart'; // Impor AppBar kustom
import 'package:provider/provider.dart';

// Widget chip kustom dari selection_screen.dart
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
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            showCheckmark: false,
            pressElevation: 0,
          ),
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
    'Edukatif & Informatif',
    'Casual & Friendly',
    'Inspirational & Motivational',
    'Fun & Energetic',
    'Luxury & Exclusive',
    'Bold & Controversial',
    'Visionary & Encouraging',
  ];
  final _targetAudienceController = TextEditingController();

  @override
  void dispose() {
    _targetAudienceController.dispose();
    super.dispose();
  }

  void _next() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<OnboardingProvider>();
      provider.toneOfVoice = _selectedTone;
      provider.targetAudience = _targetAudienceController.text;

      await provider.generateContentPillars();

      if (mounted) {
        if (provider.pillarAiResponse != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PillarResultScreen(),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(provider.errorMessage ?? 'Gagal generate pillar')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'BrandBuilder AI',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Langkah Terakhir, Tentukan Gaya Anda',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pilih gaya bicara dan untuk siapa konten Anda dibuat.',
                                style: TextStyle(
                                    color: Color(0xFF424242), fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Consumer<OnboardingProvider>(
                          builder: (context, provider, child) =>
                              ElevatedButton(
                            onPressed: provider.isLoading ? null : _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Bagian Tone of Voice
                    const Text(
                      'TONE OF VOICE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(gaya bicara yang ingin dibawakan)',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: _toneOptions.map((tone) {
                        return HoverAnimatedChip(
                          label: tone,
                          isSelected: _selectedTone == tone,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTone = selected ? tone : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 48),

                    // Bagian Target Audiens
                    const Text(
                      'TARGET AUDIENCE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(ingin membuat konten untuk siapa?)',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAudienceController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Mahasiswa, Profesional, Ibu Rumah Tangga',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFF5F5F5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: purpleColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Field ini wajib diisi' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}