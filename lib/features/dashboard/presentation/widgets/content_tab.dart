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
  static const Color _purpleColor = Color(0xFF8A53FF);
  static const Color _backgroundColor = Color(0xFFF8F9FE);
  static const Color _inkColor = Color(0xFF171717);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        final horizontalPadding = isDesktop ? 32.0 : 16.0;

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.contentScriptHistory,
              style: const TextStyle(
                color: _inkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
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
            backgroundColor: _purpleColor,
            elevation: 0,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l10n.contentGenerateNew,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: _DashboardBackground(
            child: CustomScrollView(
              slivers: [
                if (contentProvider.generatedScripts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          96,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: _ContentPanel(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _purpleColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.article_outlined,
                                    color: _purpleColor,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  l10n.contentEmptyTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _inkColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.contentEmptyBody,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      96,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            children: [
                              for (final script
                                  in contentProvider.generatedScripts)
                                ScriptHistoryCard(script: script),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1EAFF),
            _ContentTabState._backgroundColor,
            Colors.white,
          ],
          stops: [0, 0.42, 1],
        ),
      ),
      child: child,
    );
  }
}

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
