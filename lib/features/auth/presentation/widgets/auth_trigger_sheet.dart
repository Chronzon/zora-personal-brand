import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/auth/presentation/pages/login_screen.dart';

enum AuthTriggerType {
  fearOfLoss, // "Simpan data sebelum hilang"
  greedLimit, // "Buka akses unlimited"
}

class AuthTriggerSheet extends StatelessWidget {
  final AuthTriggerType type;
  final VoidCallback? onContinueAsGuest;

  const AuthTriggerSheet({
    super.key,
    required this.type,
    this.onContinueAsGuest,
  });

  // Factory method untuk mempermudah pemanggilan (OOP Encapsulation)
  static void show(BuildContext context, {
    required AuthTriggerType type,
    VoidCallback? onContinueAsGuest,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthTriggerSheet(
        type: type,
        onContinueAsGuest: onContinueAsGuest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFear = type == AuthTriggerType.fearOfLoss;
    const purpleColor = Color(0xFF8A53FF);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFear ? Colors.orange.shade50 : purpleColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFear ? Icons.warning_amber_rounded : Icons.lock_open_rounded,
              size: 48,
              color: isFear ? Colors.orange : purpleColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Headline (Value Proposition)
          Text(
            isFear ? "Amankan Strategi Brand Anda" : "Buka Akses Unlimited",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description (Context)
          Text(
            isFear
                ? "Anda sudah menganalisis SWOT dan Pilar Konten. Sayang sekali jika data ini hilang saat aplikasi ditutup. Buat akun untuk menyimpannya permanen."
                : "Kuota Guest untuk generate ide sudah habis. Login gratis sekarang untuk mendapatkan akses tanpa batas dan simpan ide-ide viralmu.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Primary Button (Login/Register)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup sheet
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Buat Akun Gratis & Simpan",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          // Secondary Button (Continue as Guest)
          // Hanya tampilkan jika ada callback onContinueAsGuest
          if (onContinueAsGuest != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup sheet
                onContinueAsGuest!(); // Jalankan aksi guest
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
              ),
              child: Text(
                "Nanti saja, lanjut sebagai Guest",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
            
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}