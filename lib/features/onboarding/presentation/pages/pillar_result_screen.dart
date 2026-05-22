import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/auth/presentation/widgets/auth_trigger_sheet.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import 'package:provider/provider.dart';

class PillarResultScreen extends StatelessWidget {
  const PillarResultScreen({super.key});

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

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pillarResultTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            onboardingProvider.pillarAiResponse ??
                                l10n.pillarResultEmpty,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: () {
                        final user = context.read<AuthProvider>().currentUser;

                        // Cek apakah user adalah Anonymous (Guest)
                        final isGuest = user != null && user.isAnonymous;

                        if (isGuest) {
                          // TAMPILKAN TRIGGER A (Fear of Loss)
                          AuthTriggerSheet.show(
                            context,
                            type: AuthTriggerType.fearOfLoss,
                            onContinueAsGuest: () {
                              // Jika user menolak login, biarkan masuk Dashboard (Risiko data hilang)
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const DashboardScreen()),
                                (route) => false,
                              );
                            },
                          );
                        } else {
                          // Jika sudah Login resmi, langsung masuk
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const DashboardScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.goToHome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
