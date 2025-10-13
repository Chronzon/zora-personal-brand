import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Ambil API Key dari .env. App akan error jika tidak ditemukan.
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-flash-latest',
    apiKey: _apiKey,
  );

  // --- FUNGSI YANG DIPERBARUI DENGAN LOGIKA RETRY ---
  Future<String?> generateContent(String prompt) async {
    const maxRetries = 3; // Coba maksimal 3 kali
    var currentDelay = const Duration(seconds: 1); // Jeda awal 1 detik

    for (int i = 0; i < maxRetries; i++) {
      try {
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        return response.text; // Jika berhasil, langsung kembalikan hasil
      } on GenerativeAIException catch (e) {
        // Cek apakah error karena server sibuk (503)
        if (e.toString().contains('503')) {
          print("Model is overloaded. Retrying in ${currentDelay.inSeconds} seconds...");
          if (i < maxRetries - 1) {
            await Future.delayed(currentDelay);
            // Gandakan jeda untuk percobaan berikutnya
            currentDelay *= 2; 
          } else {
            // Jika sudah mencapai batas percobaan, kembalikan pesan error
            print("Max retries reached. Failing.");
            return "Maaf, server AI sedang sangat sibuk. Coba lagi beberapa saat.";
          }
        } else {
          // Jika error lain (misal: API key salah), langsung gagal
          print("An unexpected AI error occurred: $e");
          rethrow;
        }
      } catch (e) {
        print("An unexpected error occurred: $e");
        rethrow; // Lemparkan error yang tidak terduga
      }
    }
    return null; // Seharusnya tidak akan pernah sampai sini
  }
}
