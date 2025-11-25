// lib/onboarding/premise_result_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/tone_of_voice_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class PremiseResultScreen extends StatefulWidget {
  const PremiseResultScreen({super.key});

  @override
  State<PremiseResultScreen> createState() => _PremiseResultScreenState();
}

class _PremiseResultScreenState extends State<PremiseResultScreen> {
  String? _selectedPremise;

  void _onNext() {
    if (_selectedPremise != null) {
      context.read<OnboardingProvider>().selectedPremise = _selectedPremise;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const ToneOfVoiceScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'BrandBuilder AI',
      ),
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
                          const Text(
                            'Here are some options for your premise',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose one that best tells your story.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Here are some options for your premise',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Choose one that best tells your story.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed:
                                _selectedPremise != null ? _onNext : null,
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Continue'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
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
                        final premise = onboardingProvider.premiseOptions[index];
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
                                  ? purpleColor.withOpacity(0.05)
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
                          onPressed: _selectedPremise != null ? _onNext : null,
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16),
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
