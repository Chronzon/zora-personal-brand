import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.language, size: 60, color: Color(0xFF8A53FF)),
              const SizedBox(height: 32),
              Text(
                "Choose Language\nPilih Bahasa",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This will affect the AI content generation.\nIni akan mempengaruhi hasil konten AI.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Tombol Indonesia
              _LanguageCard(
                flag: "🇮🇩",
                name: "Bahasa Indonesia",
                isSelected:
                    context.watch<LocaleProvider>().locale?.languageCode ==
                        'id',
                onTap: () {
                  context.read<LocaleProvider>().setLocale(const Locale('id'));
                  _navigateToWelcome(context);
                },
              ),

              const SizedBox(height: 16),

              // Tombol English
              _LanguageCard(
                flag: "🇺🇸",
                name: "English",
                isSelected:
                    context.watch<LocaleProvider>().locale?.languageCode ==
                        'en',
                onTap: () {
                  context.read<LocaleProvider>().setLocale(const Locale('en'));
                  _navigateToWelcome(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWelcome(BuildContext context) {
    // Beri sedikit delay agar user melihat efek klik
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A53FF).withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8A53FF) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF8A53FF) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF8A53FF)),
          ],
        ),
      ),
    );
  }
}
