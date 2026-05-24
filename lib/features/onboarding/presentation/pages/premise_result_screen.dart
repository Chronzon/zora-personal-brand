// lib/onboarding/premise_result_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/tone_of_voice_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PremiseResultScreen extends StatefulWidget {
  const PremiseResultScreen({super.key});

  @override
  State<PremiseResultScreen> createState() => _PremiseResultScreenState();
}

class _PremiseResultScreenState extends State<PremiseResultScreen> {
  String? _selectedPremise;

  Future<void> _onNext() async {
    if (_selectedPremise != null) {
      final provider = context.read<OnboardingProvider>();
      provider.selectedPremise = _selectedPremise;

      final saved = await provider.saveSelectedPremise();
      if (!mounted) return;

      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? l10nFallbackError),
          ),
        );
        return;
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const ToneOfVoiceScreen(),
      ));
    }
  }

  String get l10nFallbackError => 'Failed to save your selected premise.';

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    const purpleColor = Color(0xFF8A53FF);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: l10n.appName),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final padding = isMobile ? 24.0 : 48.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.premiseResultTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.premiseResultSubtitle,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.premiseResultTitle,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.premiseResultSubtitle,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _selectedPremise != null &&
                                    !onboardingProvider.isLoading
                                ? () => _onNext()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: onboardingProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.continueButton),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          )
                        ],
                      ),
                    const SizedBox(height: 48),
                    // Menampilkan daftar premis dalam bentuk kartu
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: onboardingProvider.premiseOptions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final premise =
                            onboardingProvider.premiseOptions[index];
                        final isSelected = _selectedPremise == premise;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPremise = premise;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? purpleColor.withValues(alpha: 0.05)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? purpleColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              premise,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedPremise != null &&
                                  !onboardingProvider.isLoading
                              ? () => _onNext()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: onboardingProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.continueButton),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
