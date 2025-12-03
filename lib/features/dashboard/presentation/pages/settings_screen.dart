import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/auth/presentation/pages/login_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguageSheet(BuildContext context) {
    // Ambil teks terjemahan
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final provider = Provider.of<LocaleProvider>(context, listen: false);
        final currentLocale = context.watch<LocaleProvider>().locale;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectLanguage, // Ganti teks manual
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context: context,
                label: "Bahasa Indonesia",
                flag: "🇮🇩",
                isSelected: currentLocale?.languageCode == 'id',
                onTap: () {
                  provider.setLocale(const Locale('id'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context: context,
                label: "English",
                flag: "🇺🇸",
                isSelected: currentLocale?.languageCode == 'en',
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ... _buildLanguageOption TETAP SAMA ...
  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const purpleColor = Color(0xFF8A53FF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? purpleColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? purpleColor : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? purpleColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: purpleColor, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = onboardingProvider.userProfile;
    final l10n = AppLocalizations.of(context)!;
    final isGuest =
        Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settingsTitle, // GANTI
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // --- SECTION 1: ACCOUNT ---
            _buildSectionHeader(l10n.accountSection),
            if (isGuest)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          "Akun Tamu (Guest)",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Data Anda tidak tersimpan di cloud dan akan hilang jika aplikasi dihapus.",
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.orange.shade800),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Arahkan ke Login Screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Daftar / Login Sekarang"),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: onboardingProvider.profileImage != null
                            ? FileImage(onboardingProvider.profileImage!)
                            : null,
                        child: onboardingProvider.profileImage == null
                            ? Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0]
                                    : 'U',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user.fullName,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(l10n.starterPlan,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.grey)), // GANTI
                    ),
                    const Divider(height: 1, indent: 20),
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: l10n.editProfile, // GANTI
                      onTap: () {
                        // Navigasi ke halaman edit profil
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // --- SECTION 2: PREFERENCES ---
            _buildSectionHeader(l10n.preferencesSection), // GANTI
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: l10n.languageTitle, // GANTI
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localeProvider.languageName,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _showLanguageSheet(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.darkMode, // GANTI
                    trailing: Switch(
                      value: false,
                      onChanged: (val) {},
                      activeColor: const Color(0xFF8A53FF),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 3: SUPPORT ---
            _buildSectionHeader(l10n.supportSection), // GANTI
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: l10n.helpFaq, // GANTI
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy, // GANTI
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: l10n.aboutApp, // GANTI
                    trailing: const Text("v1.0.0",
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 4: ACTIONS ---
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      l10n.logOut, // GANTI
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                l10n.madeWithLove, // GANTI
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}
