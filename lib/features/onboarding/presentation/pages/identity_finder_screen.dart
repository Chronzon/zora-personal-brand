// lib/onboarding/identity_finder_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/selection_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/swot_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

class IdentityFinderScreen extends StatefulWidget {
  const IdentityFinderScreen({super.key});

  @override
  State<IdentityFinderScreen> createState() => _IdentityFinderScreenState();
}

class _IdentityFinderScreenState extends State<IdentityFinderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk memantau isi field
  final _whatYouDoController = TextEditingController();
  final _coreValueController = TextEditingController();
  final _differentiatorsController = TextEditingController();
  final _revenueModelController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<OnboardingProvider>().userProfile;
    _whatYouDoController.text = userProfile.whatILove;
    _coreValueController.text = userProfile.whatImGoodAt;
    _differentiatorsController.text = userProfile.whatTheWorldNeeds;
    _revenueModelController.text = userProfile.whatICanBePaidFor;

    // Tambahkan listener ke setiap controller
    _whatYouDoController.addListener(_validateFields);
    _coreValueController.addListener(_validateFields);
    _differentiatorsController.addListener(_validateFields);
    _validateFields();
  }

  void _validateFields() {
    // Cek apakah ketiga field wajib sudah terisi
    final isEnabled = _whatYouDoController.text.isNotEmpty &&
        _coreValueController.text.isNotEmpty &&
        _differentiatorsController.text.isNotEmpty;
    // Update state jika ada perubahan
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    // Hapus controller saat widget tidak digunakan
    _whatYouDoController.dispose();
    _coreValueController.dispose();
    _differentiatorsController.dispose();
    _revenueModelController.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Mulai loading
      });

      try {
        // Ambil bahasa
        final languageCode = context.read<LocaleProvider>().languageCode;
        final provider = context.read<OnboardingProvider>();

        // Pass ke fungsi
        await provider.generateIdentity(languageCode);

        if (!mounted) return;

        if (provider.aiResponse != null &&
            provider.profileNameOptions.isNotEmpty) {
          // --- PERUBAHAN DI SINI: LANGSUNG NAVIGASI KE SELECTION SCREEN ---
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SelectionScreen(
              title: l10n.profileNameSelectionTitle,
              subtitle: l10n.profileNameSelectionSubtitle,
              options: provider.profileNameOptions,
              onSelect: (value) {
                provider.selectedProfileName = value;
              },
              onNext: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SelectionScreen(
                    title: l10n.categorySelectionTitle,
                    subtitle: l10n.categorySelectionSubtitle,
                    options: provider.categoryOptions,
                    onSelect: (value) {
                      provider.selectedCategory = value;
                    },
                    onNext: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SelectionScreen(
                          title: l10n.microNicheSelectionTitle,
                          subtitle: l10n.microNicheSelectionSubtitle,
                          options: provider.microNicheOptions,
                          onSelect: (value) {
                            provider.selectedMicroNiche = value;
                          },
                          onNext: () {
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
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hentikan loading
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
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
                            l10n.identityTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.identitySubtitle,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Rata tengah vertikal
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.identityTitle,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.identitySubtitle,
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: _isLoading ? 0.0 : 1.0,
                                    child: Row(
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
                                  Opacity(
                                    opacity: _isLoading ? 1.0 : 0.0,
                                    child: const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  ),
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
                          if (isMobile)
                            Column(
                              children: [
                                AnimatedTextField(
                                  controller: _whatYouDoController,
                                  label: l10n.whatILoveLabel,
                                  info: l10n.whatILoveInfo,
                                  hint: l10n.whatILovePlaceholder,
                                  validationMessage: l10n.whatILoveValidation,
                                  onSaved: (val) => provider.whatILove = val!,
                                ),
                                const SizedBox(height: 24),
                                AnimatedTextField(
                                  controller: _coreValueController,
                                  label: l10n.whatImGoodAtLabel,
                                  info: l10n.whatImGoodAtInfo,
                                  hint: l10n.whatImGoodAtPlaceholder,
                                  validationMessage:
                                      l10n.whatImGoodAtValidation,
                                  onSaved: (val) =>
                                      provider.whatImGoodAt = val!,
                                ),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AnimatedTextField(
                                    controller: _whatYouDoController,
                                    label: l10n.whatILoveLabel,
                                    info: l10n.whatILoveInfo,
                                    hint: l10n.whatILovePlaceholder,
                                    validationMessage: l10n.whatILoveValidation,
                                    onSaved: (val) => provider.whatILove = val!,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: AnimatedTextField(
                                    controller: _coreValueController,
                                    label: l10n.whatImGoodAtLabel,
                                    info: l10n.whatImGoodAtInfo,
                                    hint: l10n.whatImGoodAtPlaceholder,
                                    validationMessage:
                                        l10n.whatImGoodAtValidation,
                                    onSaved: (val) =>
                                        provider.whatImGoodAt = val!,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          if (isMobile)
                            Column(
                              children: [
                                AnimatedTextField(
                                  controller: _differentiatorsController,
                                  label: l10n.whatTheWorldNeedsLabel,
                                  info: l10n.whatTheWorldNeedsInfo,
                                  hint: l10n.whatTheWorldNeedsPlaceholder,
                                  validationMessage:
                                      l10n.whatTheWorldNeedsValidation,
                                  onSaved: (val) =>
                                      provider.whatTheWorldNeeds = val!,
                                ),
                                const SizedBox(height: 24),
                                AnimatedTextField(
                                  controller: _revenueModelController,
                                  label: l10n.whatICanBePaidForLabel,
                                  info: l10n.whatICanBePaidForInfo,
                                  hint: l10n.whatICanBePaidForPlaceholder,
                                  validationMessage:
                                      l10n.whatICanBePaidForValidation,
                                  onSaved: (val) =>
                                      provider.whatICanBePaidFor = val ?? '',
                                  isOptional: true,
                                ),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AnimatedTextField(
                                    controller: _differentiatorsController,
                                    label: l10n.whatTheWorldNeedsLabel,
                                    info: l10n.whatTheWorldNeedsInfo,
                                    hint: l10n.whatTheWorldNeedsPlaceholder,
                                    validationMessage:
                                        l10n.whatTheWorldNeedsValidation,
                                    onSaved: (val) =>
                                        provider.whatTheWorldNeeds = val!,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: AnimatedTextField(
                                    controller: _revenueModelController,
                                    label: l10n.whatICanBePaidForLabel,
                                    info: l10n.whatICanBePaidForInfo,
                                    hint: l10n.whatICanBePaidForPlaceholder,
                                    validationMessage:
                                        l10n.whatICanBePaidForValidation,
                                    onSaved: (val) =>
                                        provider.whatICanBePaidFor = val ?? '',
                                    isOptional: true,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: MouseRegion(
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: _isLoading ? 0.0 : 1.0,
                                  child: Row(
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
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                                ),
                                Opacity(
                                  opacity: _isLoading ? 1.0 : 0.0,
                                  child: const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

// Widget baru yang stateful untuk menangani animasi field
class AnimatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String info;
  final String validationMessage;
  final Function(String?) onSaved;
  final bool isOptional;

  const AnimatedTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    required this.info,
    required this.validationMessage,
    required this.onSaved,
    this.isOptional = false,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Tooltip(
      message: widget.info,
      child: TextFormField(
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
          suffixIcon: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.info_outline_rounded, color: Colors.grey),
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
          if (!widget.isOptional && (value == null || value.trim().isEmpty)) {
            return widget.validationMessage;
          }
          return null;
        },
      ),
    );
  }
}
