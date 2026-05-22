import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/features/auth/presentation/pages/login_screen.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _purpleColor = Color(0xFF8A53FF);
  static const Color _backgroundColor = Color(0xFFF8F9FE);
  static const Color _darkColor = Color(0xFF171717);

  bool _isIndonesian(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'id';
  }

  String _copy(
    BuildContext context, {
    required String id,
    required String en,
  }) {
    return _isIndonesian(context) ? id : en;
  }

  void _showLanguageSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final provider = Provider.of<LocaleProvider>(context, listen: false);
        final currentLocale = context.watch<LocaleProvider>().locale;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIconBubble(
                      icon: Icons.language_rounded,
                      backgroundColor: _purpleColor.withValues(alpha: 0.1),
                      iconColor: _purpleColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.selectLanguage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildLanguageOption(
                  context: context,
                  label: 'Bahasa Indonesia',
                  flag: 'ID',
                  isSelected: currentLocale?.languageCode == 'id',
                  onTap: () {
                    provider.setLocale(const Locale('id'));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: 'English',
                  flag: 'EN',
                  isSelected: currentLocale?.languageCode == 'en',
                  onTap: () {
                    provider.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? _purpleColor.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _purpleColor : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _purpleColor.withValues(alpha: 0.12)
                      : _backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  flag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _purpleColor : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? _purpleColor : _darkColor,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _purpleColor,
                  size: 22,
                ),
              ),
            ],
          ),
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
    final isGuest = authProvider.currentUser?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final horizontalPadding = isWide ? 40.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, l10n),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _buildAccountSection(
                                    context: context,
                                    l10n: l10n,
                                    user: user,
                                    onboardingProvider: onboardingProvider,
                                    isGuest: isGuest,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildActionSection(
                                    context: context,
                                    l10n: l10n,
                                    authProvider: authProvider,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  _buildPreferencesSection(
                                    context: context,
                                    l10n: l10n,
                                    localeProvider: localeProvider,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildSupportSection(context, l10n),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildAccountSection(
                              context: context,
                              l10n: l10n,
                              user: user,
                              onboardingProvider: onboardingProvider,
                              isGuest: isGuest,
                            ),
                            const SizedBox(height: 18),
                            _buildPreferencesSection(
                              context: context,
                              l10n: l10n,
                              localeProvider: localeProvider,
                            ),
                            const SizedBox(height: 18),
                            _buildSupportSection(context, l10n),
                            const SizedBox(height: 18),
                            _buildActionSection(
                              context: context,
                              l10n: l10n,
                              authProvider: authProvider,
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          l10n.madeWithLove,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoundIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _copy(
                  context,
                  id: 'Atur akun, bahasa, dan preferensi aplikasi.',
                  en: 'Manage your account, language, and app preferences.',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserProfile user,
    required OnboardingProvider onboardingProvider,
    required bool isGuest,
  }) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(l10n.accountSection),
          const SizedBox(height: 16),
          if (isGuest)
            _buildGuestCard(context)
          else
            _buildProfileCard(
              context: context,
              l10n: l10n,
              user: user,
              onboardingProvider: onboardingProvider,
            ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconBubble(
                icon: Icons.warning_amber_rounded,
                backgroundColor: Colors.orange.withValues(alpha: 0.14),
                iconColor: Colors.orange.shade800,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _copy(
                        context,
                        id: 'Akun Tamu',
                        en: 'Guest Account',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _copy(
                        context,
                        id: 'Data lokal bisa hilang jika aplikasi dihapus.',
                        en: 'Local data may be lost if the app is removed.',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(
                _copy(
                  context,
                  id: 'Daftar / Login Sekarang',
                  en: 'Register / Login Now',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserProfile user,
    required OnboardingProvider onboardingProvider,
  }) {
    final displayName = user.fullName.isNotEmpty
        ? user.fullName
        : _copy(context, id: 'Creator', en: 'Creator');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _purpleColor,
                      _purpleColor.withValues(alpha: 0.58),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: onboardingProvider.profileImage != null
                      ? FileImage(onboardingProvider.profileImage!)
                      : null,
                  child: onboardingProvider.profileImage == null
                      ? Text(
                          initial,
                          style: GoogleFonts.plusJakartaSans(
                            color: _purpleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _darkColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _purpleColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.starterPlan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _purpleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.person_outline_rounded,
          title: l10n.editProfile,
          subtitle: _copy(
            context,
            id: 'Perbarui identitas dan foto profil',
            en: 'Update identity and profile photo',
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPreferencesSection({
    required BuildContext context,
    required AppLocalizations l10n,
    required LocaleProvider localeProvider,
  }) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(l10n.preferencesSection),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: l10n.languageTitle,
            subtitle: localeProvider.languageName,
            trailing: _buildChevron(),
            onTap: () => _showLanguageSheet(context),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            subtitle: _copy(
              context,
              id: 'Belum tersedia',
              en: 'Coming soon',
            ),
            trailing: const Switch(
              value: false,
              onChanged: null,
              activeThumbColor: _purpleColor,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context, AppLocalizations l10n) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(l10n.supportSection),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: l10n.helpFaq,
            subtitle: _copy(
              context,
              id: 'Panduan penggunaan aplikasi',
              en: 'Guides for using the app',
            ),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: _copy(
              context,
              id: 'Lihat kebijakan data dan privasi',
              en: 'Review data and privacy policy',
            ),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutApp,
            subtitle: 'Personal Branding - Zora',
            trailing: Text(
              'v1.0.0',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection({
    required BuildContext context,
    required AppLocalizations l10n,
    required AuthProvider authProvider,
  }) {
    return _SettingsCard(
      child: _buildSettingsTile(
        icon: Icons.logout_rounded,
        title: l10n.logOut,
        subtitle: _copy(
          context,
          id: 'Keluar dari akun saat ini',
          en: 'Sign out from the current account',
        ),
        iconBackgroundColor: Colors.red.withValues(alpha: 0.08),
        iconColor: Colors.red.shade600,
        titleColor: Colors.red.shade600,
        trailing: _buildChevron(color: Colors.red.shade300),
        onTap: () async {
          await authProvider.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
    Color? iconBackgroundColor,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _buildIconBubble(
                icon: icon,
                backgroundColor:
                    iconBackgroundColor ?? _purpleColor.withValues(alpha: 0.08),
                iconColor: iconColor ?? _purpleColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: titleColor ?? _darkColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing ?? _buildChevron(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: _darkColor,
        tooltip: tooltip,
      ),
    );
  }

  static Widget _buildIconBubble({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 21),
    );
  }

  Widget _buildChevron({Color? color}) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: color ?? Colors.grey.shade400,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
