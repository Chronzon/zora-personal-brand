import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/content_factory_item.dart';
import '../providers/content_creation_provider.dart';
import 'script_detail_screen.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

class IdeaDetailScreen extends StatelessWidget {
  final ContentIdea idea;
  final String pillar;
  final int ideaNumber;
  final int totalIdeas;

  const IdeaDetailScreen({
    super.key,
    required this.idea,
    required this.pillar,
    required this.ideaNumber,
    required this.totalIdeas,
  });

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Idea #$ideaNumber",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$ideaNumber of $totalIdeas",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bookmark feature coming soon!")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing:
                    8.0, // Jarak horizontal antar badge (pengganti SizedBox width)
                runSpacing:
                    8.0, // Jarak vertikal jika badge turun ke baris kedua
                crossAxisAlignment:
                    WrapCrossAlignment.center, // Agar sejajar tengah vertikal
                children: [
                  // --- PILLAR BADGE (Tetap sama) ---
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: purpleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pillar.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: purpleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Platform Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(idea.platform),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPlatformIcon(idea.platform),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          idea.platform,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          idea.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Angle
                  _buildDetailSection(
                    icon: Icons.camera_alt_outlined,
                    label: "Angle",
                    content: idea.angle,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),

                  // Content Overview
                  _buildDetailSection(
                    icon: Icons.description_outlined,
                    label: "Content Overview",
                    content: idea.contentOverview,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),

                  // Viral Potential
                  _buildDetailSection(
                    icon: Icons.trending_up,
                    label: "Viral Potential",
                    content: idea.viralPotential,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),

                  // Insight
                  _buildDetailSection(
                    icon: Icons.lightbulb_outline,
                    label: "Insight",
                    content: idea.insight,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            // Generate Script Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ContentCreationProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );

                        // Generate script
                        final languageCode =
                            context.read<LocaleProvider>().languageCode;
                        final script = await provider.generateScript(
                            idea, pillar, languageCode);

                        // Close loading
                        if (context.mounted) Navigator.pop(context);

                        if (script != null) {
                          // Navigate to script detail
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScriptDetailScreen(script: script),
                              ),
                            );
                          }
                        } else {
                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Failed to generate script. Please try again."),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.article_outlined, size: 22),
                      label: Text(
                        "Generate Script",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return Colors.black;
      case 'instagram reels':
      case 'instagram post':
      case 'instagram':
        return const Color(0xFFE4405F); // Instagram pink
      case 'youtube shorts':
      case 'youtube video':
      case 'youtube':
        return const Color(0xFFFF0000); // YouTube red
      case 'linkedin post':
      case 'linkedin':
        return const Color(0xFF0077B5); // LinkedIn blue
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return Icons.music_note; // TikTok placeholder
      case 'instagram reels':
      case 'instagram post':
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube shorts':
      case 'youtube video':
      case 'youtube':
        return Icons.play_circle_filled;
      case 'linkedin post':
      case 'linkedin':
        return Icons.work;
      default:
        return Icons.public;
    }
  }
}
