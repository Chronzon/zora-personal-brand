import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/generated_script.dart';
import '../pages/script_detail_screen.dart';

class ScriptHistoryCard extends StatelessWidget {
  final GeneratedScript script;

  const ScriptHistoryCard({
    super.key,
    required this.script,
  });

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                builder: (context) => ScriptDetailScreen(script: script),
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
                        color: purpleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.article,
                          color: purpleColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            script.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(script.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getScriptPreview(script.script),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  // <--- GANTI ROW JADI WRAP
                  spacing: 8.0, // Jarak horizontal
                  runSpacing: 8.0, // Jarak vertikal jika turun baris
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildBadge(script.pillar, purpleColor),
                    // Hapus SizedBox(width: 8) karena sudah dihandle 'spacing'
                    _buildPlatformBadge(script.platform),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPlatformBadge(String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getPlatformColor(platform).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPlatformColor(platform).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPlatformIcon(platform),
            size: 12,
            color: _getPlatformColor(platform),
          ),
          const SizedBox(width: 4),
          Text(
            platform,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getPlatformColor(platform),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getScriptPreview(String script) {
    final lines =
        script.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return lines.take(2).join(' ').trim();
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
