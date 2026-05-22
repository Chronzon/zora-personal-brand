import 'package:flutter/material.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../content_creation/presentation/providers/content_creation_provider.dart';
import '../../../content_creation/presentation/widgets/create_idea_sheet.dart';
import '../../../content_creation/presentation/widgets/script_history_card.dart';

class ContentTab extends StatefulWidget {
  const ContentTab({super.key});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateIdeaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = context.watch<ContentCreationProvider>();
    final l10n = AppLocalizations.of(context)!;
    const purpleColor = Color(0xFF8A53FF);

    // Gunakan LayoutBuilder untuk responsif
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Untuk desktop mungkin pakai Dialog, mobile pakai BottomSheet
              if (isDesktop) {
                showDialog(
                  context: context,
                  builder: (context) => const Dialog(
                    child: SizedBox(width: 500, child: CreateIdeaSheet()),
                  ),
                );
              } else {
                _showCreateSheet(context);
              }
            },
            backgroundColor: Colors.black,
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l10n.contentGenerateNew,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    l10n.contentScriptHistory,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.deepPurple.shade50, Colors.white],
                      ),
                    ),
                  ),
                ),
              ),
              if (contentProvider.generatedScripts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.deepPurple.shade100,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10))
                            ],
                          ),
                          child: const Icon(Icons.article_outlined,
                              size: 48, color: purpleColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.contentEmptyTitle,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.contentEmptyBody,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ScriptHistoryCard(
                        script: contentProvider.generatedScripts[index],
                      ),
                      childCount: contentProvider.generatedScripts.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
