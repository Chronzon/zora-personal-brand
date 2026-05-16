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
    final hooks = [
      "Stop melakukan kesalahan ini jika ingin sukses di...",
      "Rahasia yang tidak pernah diberitahu oleh guru...",
      "3 Cara instan untuk meningkatkan...",
      "Bagaimana saya mengubah X menjadi Y dalam 30 hari...",
      "Alasan kenapa strategi lama kamu gagal...",
      "Ini dia alat rahasia yang saya gunakan untuk...",
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
                  "Viral Hooks Vault",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Copy template judul ini untuk video/postinganmu selanjutnya:",
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
                      const SnackBar(
                          content: Text("Hook copied to clipboard!")),
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
    const purpleColor = Color(0xFF8A53FF);

    final user = onboardingProvider.userProfile;
    final isOnboardingComplete = onboardingProvider.isOnboardingComplete;

    final firstName =
        user.fullName.isNotEmpty ? user.fullName.split(' ').first : 'Creator';

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
                          'Hi, $firstName 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Siap membangun brand hari ini?',
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
                          color: Colors.black.withOpacity(0.05),
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
                      tooltip: 'Settings',
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              if (!isOnboardingComplete)
                _buildIncompleteSetupCard(context, purpleColor)
              else ...[
                _buildDailySparkCard(_dailyPillar ?? "General", purpleColor),
                const SizedBox(height: 16),
                _buildUpdateStrategyButton(context, purpleColor),
              ],

              const SizedBox(height: 24),

              // 3. Quick Actions (Tombol Diperbarui)
              Text(
                "Quick Actions",
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
                      title: "Generate\nNew Idea",
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
                      title: "Viral Hooks\nVault",
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
                    "Recent Scripts",
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
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(contentProvider.generatedScripts.length, 3),
                  itemBuilder: (context, index) {
                    final script = contentProvider.generatedScripts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
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
                            color: purpleColor.withOpacity(0.1),
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
                                child:
                                    _buildMiniTag(script.platform, Colors.blue),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
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
                  color: color.withOpacity(0.1),
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
                      "Your brand strategy is not complete yet.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Complete your setup so Zora can personalize your content ideas and scripts.",
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
              label: const Text("Continue Setup"),
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openBrandSetup(context, showBackButton: true),
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: const Text("Update Brand Strategy"),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.35)),
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
                  : color.withOpacity(0.25), // Shadow halus
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
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.white.withOpacity(0.15),
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

  Widget _buildDailySparkCard(String pillar, Color color) {
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
            color: color.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("⚡ Daily Spark",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        "• $cleanPillar",
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
            "Audiens butuh konten $cleanPillar hari ini.",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Yuk buat konten yang relevan untuk meningkatkan interaksi dengan niche kamu.",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.9),
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
        color: color.withOpacity(0.1),
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

  Widget _buildEmptyState() {
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
            "Belum ada history",
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          Text(
            "Mulai generate ide sekarang!",
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
