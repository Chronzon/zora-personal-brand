import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/content_factory_item.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

class IdeaResultCard extends StatefulWidget {
  final ContentFactoryItem factoryItem;

  const IdeaResultCard({
    super.key,
    required this.factoryItem,
  });

  @override
  State<IdeaResultCard> createState() => _IdeaResultCardState();
}

class _IdeaResultCardState extends State<IdeaResultCard> {
  bool _isExpanded = false;

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);
    final item = widget.factoryItem;

    final pillarTitle =
        item.selectedPillar?.replaceAll(RegExp(r'^\d+\.\s*'), '') ?? 'General';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded,
                      color: purpleColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pillarTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${item.ideaCount} Ideas Generated",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.isLoading)
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text("Meracik ide viral...",
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          else if (item.ideas != null && item.ideas!.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: item.ideas!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final idea = item.ideas![index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: purpleColor,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              idea.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          Icons.camera_alt_outlined, "Angle", idea.angle),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.description_outlined, "Overview",
                          idea.contentOverview),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.trending_up, "Viral Potential",
                          idea.viralPotential),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.lightbulb_outline, "Insight", idea.insight),
                    ],
                  ),
                );
              },
            )
          else if (item.generatedIdeas != null)
            Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: _isExpanded ? double.infinity : 200,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: MarkdownBody(
                    data: item.generatedIdeas!,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                          fontSize: 15, height: 1.6, color: Colors.black87),
                      strong: const TextStyle(
                          fontWeight: FontWeight.bold, color: purpleColor),
                      listBullet: const TextStyle(color: purpleColor),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isExpanded ? "Tutup" : "Lihat Selengkapnya",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    final languageCode =
                        context.read<LocaleProvider>().languageCode;
                    context
                        .read<ContentCreationProvider>()
                        .generateContentIdeas(item.id, languageCode);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Coba Generate Ulang"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
