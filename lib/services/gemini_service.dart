import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // GANTI DENGAN API KEY ANDA
  static const String _apiKey = 'AIzaSyD54GRWhjxgETd7stxPUaIVkCKJtx-BwXk';

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash', // atau model lain yang tersedia
    apiKey: _apiKey,
  );

  Future<String?> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      print("Error generating content: $e");
      return "Maaf, terjadi kesalahan saat menghubungi AI.";
    }
  }
}