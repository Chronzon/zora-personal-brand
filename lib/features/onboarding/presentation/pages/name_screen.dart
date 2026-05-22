import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/identity_finder_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class NameScreen extends StatefulWidget {
  final bool showBackButton;

  const NameScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<OnboardingProvider>().userProfile.fullName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      Provider.of<OnboardingProvider>(context, listen: false)
          .updateFullName(_controller.text);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const IdentityFinderScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor =
        Color(0xFF8A53FF); // Sesuaikan dengan warna branding Anda
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      // Kita tidak menggunakan AppBar bawaan Scaffold agar layout lebih fleksibel
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          // Padding yang responsif: lebih lebar di Desktop agar tidak terlalu melebar
          final horizontalPadding = isMobile ? 24.0 : 48.0;

          return Column(
            children: [
              // -----------------------------------------------------------
              // 1. HEADER CUSTOM (Logo & Back Button)
              // -----------------------------------------------------------
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Kembali (Opsional: untuk kembali ke Welcome Screen)
                    if (widget.showBackButton)
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                      )
                    else
                      const SizedBox(width: 48),

                    // Logo Aplikasi (Kecil di tengah atau kanan)
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: purpleColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.appName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (widget.showBackButton)
                      const SizedBox(width: 48)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),

              // -----------------------------------------------------------
              // 2. KONTEN UTAMA (Teks & Form Input)
              // -----------------------------------------------------------
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    // Membatasi lebar konten di layar besar agar enak dibaca
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Headline Besar
                          Text(
                            l10n.brandNameTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isMobile ? 32 : 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle Penjelas
                          Text(
                            l10n.brandNameSubtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Form Input Nama
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _controller,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign
                                      .center, // Teks di tengah agar fokus
                                  decoration: InputDecoration(
                                    labelText: l10n.brandNameInputLabel,
                                    helperText: l10n.brandNameInputInfo,
                                    helperMaxLines: 2,
                                    hintText: l10n.brandNameInputPlaceholder,
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                    suffixIcon: Tooltip(
                                      message: l10n.brandNameInputInfo,
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    // Border saat tidak aktif (halus)
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1),
                                    ),
                                    // Border saat diketik (ungu)
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: purpleColor, width: 2),
                                    ),
                                    // Border saat error
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  validator: (value) => value!.trim().isEmpty
                                      ? l10n.brandNameValidation
                                      : null,
                                  onFieldSubmitted: (_) =>
                                      _next(), // Enter = Next
                                ),
                                const SizedBox(height: 24),

                                // Tombol Lanjut Besar
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      64, // Tombol tinggi agar mudah ditekan
                                  child: ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: purpleColor,
                                      foregroundColor: Colors.white,
                                      elevation: 10,
                                      shadowColor:
                                          purpleColor.withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.continueButton,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.arrow_forward_rounded,
                                            size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Elemen Kepercayaan (Trust Element) - Opsional
                          // Memberikan rasa aman bahwa data ini privat
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 8),
                              Text(
                                l10n.brandNamePrivacyNote,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
