// lib/screens/content_ideas_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/providers/brand_provider.dart';
import 'package:personal_branding_app/services/gemini_service.dart';
import 'package:personal_branding_app/widgets/ai_suggestion_box.dart';
import 'package:provider/provider.dart';

class ContentIdeasScreen extends StatefulWidget {
  const ContentIdeasScreen({super.key});

  @override
  State<ContentIdeasScreen> createState() => _ContentIdeasScreenState();
}

class _ContentIdeasScreenState extends State<ContentIdeasScreen> {
  final GeminiService _geminiService = GeminiService();

  Future<void> _getAIContentIdeas() async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    
    if (brandProvider.contentPillars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap buat "Pilar Konten" terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    brandProvider.setLoading(true);
    final pillarsString = brandProvider.contentPillars.join(', ');

    final prompt = """
    Anda adalah seorang ahli strategi konten. Berdasarkan pilar-pilar konten berikut: "${pillarsString}"
    Tolong buatkan 10 ide konten yang kreatif dan menarik.
    Untuk setiap ide, sebutkan juga format yang disarankan (Contoh: Reel Instagram, Thread Twitter, Artikel Blog).
    Berikan jawaban dalam format daftar bernomor yang jelas.
    """;

    final result = await _geminiService.generateContent(prompt);
    brandProvider.setLoading(false);

    if (result != null && result.isNotEmpty) {
      final ideas = result
          .split('\n')
          .where((s) => s.isNotEmpty && s.contains(RegExp(r'^\d+\.')))
          .toList();
      brandProvider.setIdeas(ideas);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan ide dari AI. Coba lagi nanti.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Text(
          '3. Kembangkan Ide Konten',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sekarang, kembangkan ide-ide konten konkret dari setiap pilar yang sudah kamu tentukan. Biarkan AI memberikanmu inspirasi!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text("Minta Ide Konten dari AI", style: TextStyle(fontSize: 16)),
          onPressed: _getAIContentIdeas,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Menggunakan AiSuggestionBox Widget
        Consumer<BrandProvider>(
          builder: (context, provider, child) {
            return AiSuggestionBox(
              title: 'Hasil Ide Konten:',
              isLoading: provider.isLoading,
              suggestions: provider.contentIdeas,
              emptyText: "Belum ada ide konten.\nKlik tombol di atas untuk memulai!",
              icon: Icons.lightbulb_outline,
            );
          },
        ),
      ],
    );
  }
}
