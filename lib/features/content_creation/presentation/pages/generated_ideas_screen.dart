import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/content_factory_item.dart';
import 'idea_detail_screen.dart';

class GeneratedIdeasScreen extends StatefulWidget {
  final String rawContent;
  final List<ContentIdea>? ideas;
  final String pillar;

  const GeneratedIdeasScreen({
    super.key,
    required this.rawContent,
    this.ideas,
    required this.pillar,
  });

  @override
  State<GeneratedIdeasScreen> createState() => _GeneratedIdeasScreenState();
}

class _GeneratedIdeasScreenState extends State<GeneratedIdeasScreen> {
  List<ContentIdea> _ideas = [];

  @override
  void initState() {
    super.initState();
    _prepareContent();
  }

  void _prepareContent() {
    if (widget.ideas != null && widget.ideas!.isNotEmpty) {
      _ideas = widget.ideas!;
    }
  }

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
              "Content Ideas",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${_ideas.length} ideas generated",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: _ideas.isEmpty
          ? Center(
              child: Text(
                "No ideas available",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ideas.length,
              itemBuilder: (context, index) {
                final idea = _ideas[index];
                return _buildSummaryCard(idea, index, purpleColor);
              },
            ),
    );
  }

  Widget _buildSummaryCard(ContentIdea idea, int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IdeaDetailScreen(
                  idea: idea,
                  pillar: widget.pillar,
                  ideaNumber: index + 1,
                  totalIdeas: _ideas.length,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(Icons.lightbulb_rounded, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "#${index + 1}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  idea.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  idea.contentOverview,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.trending_up,
                        size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        idea.viralPotential,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Platform Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getPlatformColor(idea.platform).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPlatformColor(idea.platform)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(idea.platform),
                        size: 12,
                        color: _getPlatformColor(idea.platform),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        idea.platform,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPlatformColor(idea.platform),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return Colors.black;
      case 'instagram reels':
      case 'instagram post':
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'youtube shorts':
      case 'youtube video':
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'linkedin post':
      case 'linkedin':
        return const Color(0xFF0077B5);
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return Icons.music_note;
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
