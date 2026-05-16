import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/auth/presentation/pages/login_screen.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/name_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data Slide Intro
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Personal Branding\nBerbasis AI",
      "desc":
          "Biarkan AI menganalisis Ikigai Anda dan merancang strategi branding yang 100% unik dan otentik.",
      "icon": "✨" // Bisa diganti Image Asset nanti
    },
    {
      "title": "Ide Konten Tanpa Batas",
      "desc":
          "Jangan pernah kehabisan ide. Dapatkan ratusan ide konten viral yang disesuaikan dengan Niche Anda.",
      "icon": "💡"
    },
    {
      "title": "Script Siap Posting",
      "desc":
          "Dari ide menjadi naskah video TikTok atau Caption Instagram hanya dalam hitungan detik.",
      "icon": "🚀"
    },
  ];

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER: Tombol Login (Untuk User Lama)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: purpleColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. CONTENT: Carousel / Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() => _currentPage = value);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder Ilustrasi (Bisa diganti Image.asset)
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: purpleColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _onboardingData[index]["icon"]!,
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. FOOTER: Indicator & Main Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? purpleColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Utama "Mulai" -> Ke Name Screen
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final user = context.read<AuthProvider>().currentUser;
                        final hasRealUser = user != null && !user.isAnonymous;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => hasRealUser
                                ? const NameScreen()
                                : const LoginScreen(showBackButton: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        foregroundColor: Colors.white,
                        elevation: 10, // Shadow biar megah
                        shadowColor: purpleColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Mulai Branding Sekarang",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
