import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/content_creation/presentation/pages/script_detail_screen.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/content_creation/presentation/widgets/create_idea_sheet.dart';
import 'package:personal_branding_app/features/dashboard/presentation/pages/settings_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/name_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _dailyPillar;

  @override
  void initState() {
    super.initState();
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateIdeaSheet(),
    );
  }

  void _openBrandSetup(BuildContext context, {required bool showBackButton}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NameScreen(showBackButton: showBackButton),
      ),
    );
  }

  void _showViralHooksSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hooks = [
      l10n.hookTemplateOne,
      l10n.hookTemplateTwo,
      l10n.hookTemplateThree,
      l10n.hookTemplateFour,
      l10n.hookTemplateFive,
      l10n.hookTemplateSix,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.viralHooksTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.viralHooksSubtitle,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ...hooks.map((hook) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  title: Text(hook,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: hook));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.hookCopied)),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _cleanPillarName(String rawPillar) {
    if (rawPillar.contains('(')) {
      return rawPillar.split('(')[0].trim();
    } else if (rawPillar.contains(':')) {
      return rawPillar.split(':')[0].trim();
    }
    return rawPillar;
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final contentProvider = context.watch<ContentCreationProvider>();
    final l10n = AppLocalizations.of(context)!;
    const purpleColor = Color(0xFF8A53FF);

    final user = onboardingProvider.userProfile;
    final isOnboardingComplete = onboardingProvider.isOnboardingComplete;

    final firstName = user.fullName.isNotEmpty
        ? user.fullName.split(' ').first
        : l10n.creatorFallback;

    if (_dailyPillar == null &&
        onboardingProvider.contentPillarOptions.isNotEmpty) {
      final pillars = onboardingProvider.contentPillarOptions;
      _dailyPillar = pillars[Random().nextInt(pillars.length)];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting(firstName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          l10n.homeReadySubtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.black87,
                      tooltip: l10n.settingsTooltip,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              if (!isOnboardingComplete)
                _buildIncompleteSetupCard(context, purpleColor)
              else ...[
                _buildDailySparkCard(
                    context, _dailyPillar ?? l10n.defaultPillar, purpleColor),
                const SizedBox(height: 16),
                _buildUpdateStrategyButton(context, purpleColor),
              ],

              const SizedBox(height: 24),

              // 3. Quick Actions (Tombol Diperbarui)
              Text(
                l10n.quickActions,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    // --- UPDATE 2: TOMBOL HITAM (Premium Look) ---
                    child: _buildActionCard(
                      title: l10n.generateNewIdea,
                      icon: Icons.auto_awesome,
                      // Ganti warna jadi HITAM PEKAT
                      color: const Color(0xFF1A1A1A),
                      // Icon jadi Ungu/Putih biar pop
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () => _showCreateSheet(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    // --- UPDATE 3: TOMBOL VIRAL (White Card) ---
                    child: _buildActionCard(
                      title: l10n.viralHooksVault,
                      icon: Icons.flash_on_rounded,
                      color: Colors.white,
                      iconColor: Colors.orange,
                      textColor: Colors.black87,
                      isSecondary: true, // Punya border
                      onTap: () => _showViralHooksSheet(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 4. Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentScripts,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (contentProvider.generatedScripts.isEmpty)
                _buildEmptyState(context)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(contentProvider.generatedScripts.length, 3),
                  itemBuilder: (context, index) {
                    final script = contentProvider.generatedScripts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        shadowColor: Colors.grey.shade200,
                        elevation: 1,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScriptDetailScreen(script: script),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: purpleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.article_outlined,
                                color: purpleColor, size: 20),
                          ),
                          title: Text(
                            script.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: _buildMiniTag(
                                      script.platform, Colors.blue),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: _buildMiniTag(
                                    _cleanPillarName(script.pillar),
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS UPDATE ---

  Widget _buildIncompleteSetupCard(BuildContext context, Color color) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flag_outlined, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.incompleteSetupTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.incompleteSetupBody,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openBrandSetup(
                context,
                showBackButton: false,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(l10n.continueSetup),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStrategyButton(BuildContext context, Color color) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openBrandSetup(context, showBackButton: true),
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: Text(l10n.updateBrandStrategy),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? iconColor, // Parameter baru untuk kontrol warna icon
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24), // Lebih bulat (Modern)
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isSecondary ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: isSecondary
                  ? Colors.grey.shade200
                  : color.withValues(alpha: 0.25), // Shadow halus
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Logic warna background icon
                color: isSecondary
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    iconColor ?? (isSecondary ? Colors.orange : Colors.white),
                size: 26,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700, // Extra Bold
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySparkCard(
      BuildContext context, String pillar, Color color) {
    final l10n = AppLocalizations.of(context)!;
    final cleanPillar = _cleanPillarName(pillar);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Gradient Ungu tetap di sini karena ini "Hero" section
        gradient: LinearGradient(
          colors: [color, const Color(0xFF6026F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.dailySpark,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        l10n.dailySparkPillar(cleanPillar),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dailySparkHeadline(cleanPillar),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dailySparkBody,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            l10n.noHistoryTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          Text(
            l10n.noHistoryBody,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
