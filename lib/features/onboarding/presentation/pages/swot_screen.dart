// lib/onboarding/swot_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/premise_result_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

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
    final onboardingProvider = context.read<OnboardingProvider>();
    _strengthsController.text =
        onboardingProvider.brandProfile.strengths.isNotEmpty
            ? onboardingProvider.brandProfile.strengths
            : onboardingProvider.userProfile.whatImGoodAt;
    _weaknessesController.text = onboardingProvider.brandProfile.weaknesses;
    _threatsController.text = onboardingProvider.brandProfile.threats;

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
        final languageCode = context.read<LocaleProvider>().languageCode;
        final provider = context.read<OnboardingProvider>();

        await provider.generatePremise(languageCode);

        if (!mounted) return;

        if (provider.premiseAiResponse != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PremiseResultScreen(),
          ));
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
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
    final onboardingProvider = context.read<OnboardingProvider>();
    const purpleColor = Color(0xFF8A53FF);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: l10n.appName),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final padding = isMobile ? 24.0 : 48.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.detectorTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.detectorSubtitle,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.detectorTitle,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.detectorSubtitle,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                          MouseRegion(
                            cursor: _isButtonEnabled && !_isLoading
                                ? SystemMouseCursors.click
                                : SystemMouseCursors.forbidden,
                            child: ElevatedButton(
                              onPressed: _isButtonEnabled && !_isLoading
                                  ? _generate
                                  : null,
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
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.continueButton,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward,
                                            size: 16),
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
                            label: l10n.strengthsLabel,
                            info: l10n.strengthsInfo,
                            hint: l10n.strengthsPlaceholder,
                            validationMessage: l10n.strengthsValidation,
                            onSaved: (val) =>
                                onboardingProvider.strengths = val!,
                          ),
                          const SizedBox(height: 24),
                          AnimatedTextField(
                            controller: _weaknessesController,
                            label: l10n.weaknessesLabel,
                            info: l10n.weaknessesInfo,
                            hint: l10n.weaknessesPlaceholder,
                            validationMessage: l10n.weaknessesValidation,
                            onSaved: (val) =>
                                onboardingProvider.weaknesses = val!,
                          ),
                          const SizedBox(height: 24),
                          AnimatedTextField(
                            controller: _threatsController,
                            label: l10n.threatsLabel,
                            info: l10n.threatsInfo,
                            hint: l10n.threatsPlaceholder,
                            validationMessage: l10n.threatsValidation,
                            onSaved: (val) => onboardingProvider.threats = val!,
                          ),
                          if (isMobile) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isButtonEnabled && !_isLoading
                                    ? _generate
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: purpleColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 22),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.0),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(l10n.continueButton,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward,
                                              size: 16),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Widget ini bisa dipindahkan ke file terpisah jika diinginkan
class AnimatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String info;
  final String validationMessage;
  final Function(String?) onSaved;

  const AnimatedTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    required this.info,
    required this.validationMessage,
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
      minLines: 3,
      maxLines: 5,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.info,
        helperMaxLines: 2,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixIcon: Tooltip(
          message: widget.info,
          child: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.info_outline_rounded, color: Colors.grey),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        if (value == null || value.trim().isEmpty) {
          return widget.validationMessage;
        }
        return null;
      },
    );
  }
}
