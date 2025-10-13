// lib/onboarding/swot_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/premise_result_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:personal_branding_app/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SwotScreen extends StatefulWidget {
  const SwotScreen({super.key});

  @override
  State<SwotScreen> createState() => _SwotScreenState();
}

class _SwotScreenState extends State<SwotScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();
  final _threatsController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi nilai awal untuk field kekuatan
    _strengthsController.text = context.read<OnboardingProvider>().whatImGoodAt;
    
    _strengthsController.addListener(_validateFields);
    _weaknessesController.addListener(_validateFields);
    _threatsController.addListener(_validateFields);
    _validateFields(); // Panggil sekali di awal untuk inisialisasi
  }

  void _validateFields() {
    final isEnabled = _strengthsController.text.isNotEmpty &&
                      _weaknessesController.text.isNotEmpty &&
                      _threatsController.text.isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _threatsController.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() => _isLoading = true);

      try {
        await Provider.of<OnboardingProvider>(context, listen: false).generatePremise();
        
        final provider = Provider.of<OnboardingProvider>(context, listen: false);
        if (mounted) {
            if (provider.premiseAiResponse != null) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PremiseResultScreen(),
              ));
            } else if (provider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.errorMessage!))
              );
            }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PERSONAL DETECTOR INTELLIGENCE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Analyze your strengths and challenges to build a solid foundation.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                      MouseRegion(
                        cursor: _isButtonEnabled && !_isLoading
                                ? SystemMouseCursors.click 
                                : SystemMouseCursors.forbidden,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled && !_isLoading ? _generate : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AnimatedTextField(
                          controller: _strengthsController,
                          label: 'Kekuatanmu',
                          hint: '(hal yang dikuasai & bisa dimanfaatkan)',
                          onSaved: (val) => provider.strengths = val!,
                        ),
                        const SizedBox(height: 24),
                        AnimatedTextField(
                          controller: _weaknessesController,
                          label: 'Kelemahanmu',
                          hint: '(hambatan / keterbatasan pribadi)',
                          onSaved: (val) => provider.weaknesses = val!,
                        ),
                        const SizedBox(height: 24),
                        AnimatedTextField(
                          controller: _threatsController,
                          label: 'Tantanganmu',
                          hint: '(hal yang menghambat keberhasilan)',
                          onSaved: (val) => provider.threats = val!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget ini bisa dipindahkan ke file terpisah jika diinginkan
class AnimatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final Function(String?) onSaved;

  const AnimatedTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    required this.onSaved,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return TextFormField(
      controller: widget.controller,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: purpleColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
      ),
      onSaved: widget.onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wajib diisi';
        }
        return null;
      },
    );
  }
}
