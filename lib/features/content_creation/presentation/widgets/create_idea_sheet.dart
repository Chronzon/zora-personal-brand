import 'package:flutter/material.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/auth/presentation/widgets/auth_trigger_sheet.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/content_creation_provider.dart';
import '../pages/generated_ideas_screen.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';

class CreateIdeaSheet extends StatefulWidget {
  const CreateIdeaSheet({super.key});

  @override
  State<CreateIdeaSheet> createState() => _CreateIdeaSheetState();
}

class _CreateIdeaSheetState extends State<CreateIdeaSheet> {
  String? _selectedPillar;
  double _ideaCount = 5;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final onboardingProvider = context.read<OnboardingProvider>();
    final pillars = onboardingProvider.contentPillarOptions;
    if (pillars.isNotEmpty) {
      _selectedPillar = pillars.first;
    }
  }

  Future<void> _startGenerating() async {
    setState(() => _isGenerating = true);
    final contentProvider = context.read<ContentCreationProvider>();
    final user = context.read<AuthProvider>().currentUser;

    // Cek apakah guest (user null dianggap guest atau user anonim)
    final isGuest = user == null || user.isAnonymous;

    try {
      final newId = await contentProvider.addContentFactoryWithPillar(
          _selectedPillar!, _ideaCount.toInt());

      if (newId != null && mounted) {
        final languageCode = context.read<LocaleProvider>().languageCode;
        await contentProvider.generateContentIdeas(newId, languageCode);

        // Hitung penggunaan jika Guest
        if (isGuest) {
          contentProvider.incrementGuestUsage();
        }

        final item =
            contentProvider.contentFactories.firstWhere((e) => e.id == newId);

        if (mounted) {
          Navigator.pop(context);
          if (item.generatedIdeas != null ||
              (item.ideas != null && item.ideas!.isNotEmpty)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GeneratedIdeasScreen(
                          rawContent: item.generatedIdeas ?? '',
                          ideas: item.ideas,
                          pillar: _selectedPillar!,
                        )));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.read<OnboardingProvider>();
    final pillars = onboardingProvider.contentPillarOptions;
    final l10n = AppLocalizations.of(context)!;
    const purpleColor = Color(0xFF8A53FF);

    // Validasi pilar default
    if (_selectedPillar == null || !pillars.contains(_selectedPillar)) {
      if (pillars.isNotEmpty) {
        _selectedPillar = pillars.first;
      } else {
        _selectedPillar = null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.createIdeaSheetTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(l10n.createIdeaPillarLabel,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPillar,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: purpleColor),
                items: pillars
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPillar = val),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.createIdeaCountLabel,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text(l10n.createIdeaCountValue(_ideaCount.toInt()),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: purpleColor)),
            ],
          ),
          Slider(
            value: _ideaCount,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: purpleColor,
            onChanged: (val) => setState(() => _ideaCount = val),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isGenerating
                  ? null
                  : () async {
                      if (_selectedPillar == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.createIdeaMissingPillar)),
                        );
                        return;
                      }

                      final user = context.read<AuthProvider>().currentUser;
                      final isGuest = user == null || user.isAnonymous;
                      final contentProvider =
                          context.read<ContentCreationProvider>();

                      // Cek apakah ini saatnya mengingatkan (setiap 5x)
                      if (isGuest && contentProvider.shouldShowGuestReminder) {
                        // Tampilkan Popup "Soft Limit"
                        AuthTriggerSheet.show(
                          context,
                          type: AuthTriggerType.greedLimit,

                          // Jika user pilih "Nanti Saja", tetap jalankan generate
                          onContinueAsGuest: () {
                            _startGenerating();
                          },
                        );

                        return; // Berhenti di sini, tunggu user memilih di Popup
                      }

                      _startGenerating();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.createIdeaLoadingLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(l10n.createIdeaGenerateButton,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }
}
