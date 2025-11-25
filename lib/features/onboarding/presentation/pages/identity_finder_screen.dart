// lib/onboarding/identity_finder_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/selection_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/swot_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
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

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener ke setiap controller
    _whatYouDoController.addListener(_validateFields);
    _coreValueController.addListener(_validateFields);
    _differentiatorsController.addListener(_validateFields);
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
    super.dispose();
  }

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Mulai loading
      });

      try {
        // Ambil bahasa
        final languageCode = context.read<LocaleProvider>().languageCode;
        
        // Pass ke fungsi
        await Provider.of<OnboardingProvider>(context, listen: false)
            .generateIdentity(languageCode);

        final provider =
            Provider.of<OnboardingProvider>(context, listen: false);
        if (mounted) {
          if (provider.aiResponse != null &&
              provider.profileNameOptions.isNotEmpty) {
            // --- PERUBAHAN DI SINI: LANGSUNG NAVIGASI KE SELECTION SCREEN ---
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SelectionScreen(
                title: 'Pick your profile name',
                subtitle:
                    'Choose a name that best represents your brand. This will be your identity.',
                options: provider.profileNameOptions,
                onSelect: (value) {
                  provider.selectedProfileName = value;
                },
                onNext: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SelectionScreen(
                      title: 'Select a Category',
                      subtitle:
                          'This will define the general area of your content.',
                      options: provider.categoryOptions,
                      onSelect: (value) {
                        provider.selectedCategory = value;
                      },
                      onNext: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SelectionScreen(
                            title: 'Choose a Micro-Niche',
                            subtitle:
                                'Get specific! This is where you\'ll stand out.',
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          toolbarHeight: 80.0,
          backgroundColor: Colors.white,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'BrandBuilder AI',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // Fungsi hamburger menu nanti
              },
            ),
          ],
        ),
      ),
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
                          const Text(
                            'Business Profile Setup',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You can always change these later',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Rata tengah vertikal
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Profile Setup',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'You can always change these later',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
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
                                    child: const Row(
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
                                  label: 'What You Do',
                                  tooltipMessage:
                                      'What is it that you do that you want to share?',
                                  onSaved: (val) => provider.whatILove = val!,
                                ),
                                const SizedBox(height: 24),
                                AnimatedTextField(
                                  controller: _coreValueController,
                                  label: 'Core Value Proposition',
                                  tooltipMessage:
                                      'What unique problem does your business solve?',
                                  hint:
                                      'example: "We help e-commerce brands reduce returns with AI fit recommendations"',
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
                                    label: 'What You Do',
                                    tooltipMessage:
                                        'What is it that you do that you want to share?',
                                    onSaved: (val) => provider.whatILove = val!,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: AnimatedTextField(
                                    controller: _coreValueController,
                                    label: 'Core Value Proposition',
                                    tooltipMessage:
                                        'What unique problem does your business solve?',
                                    hint:
                                        'example: "We help e-commerce brands reduce returns with AI fit recommendations"',
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
                                  label: 'Key Differentiators',
                                  tooltipMessage:
                                      'List things you do better than competitors',
                                  onSaved: (val) =>
                                      provider.whatTheWorldNeeds = val!,
                                ),
                                const SizedBox(height: 24),
                                AnimatedTextField(
                                  label: 'Revenue Model (Optional)',
                                  onSaved: (val) =>
                                      provider.whatICanBePaidFor = val!,
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
                                    label: 'Key Differentiators',
                                    tooltipMessage:
                                        'List things you do better than competitors',
                                    onSaved: (val) =>
                                        provider.whatTheWorldNeeds = val!,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: AnimatedTextField(
                                    label: 'Revenue Model (Optional)',
                                    onSaved: (val) =>
                                        provider.whatICanBePaidFor = val!,
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
                                  child: const Row(
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
  final String? tooltipMessage;
  final Function(String?) onSaved;
  final bool isOptional;

  const AnimatedTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.tooltipMessage,
    required this.onSaved,
    this.isOptional = false,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Tooltip(
      message: widget.tooltipMessage ?? '',
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: _isFocused ? widget.hint : null,
          hintStyle: const TextStyle(fontSize: 10),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
          if (!widget.isOptional && (value == null || value.isEmpty)) {
            return 'Wajib diisi';
          }
          return null;
        },
      ),
    );
  }
}
