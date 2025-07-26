// lib/screens/content_pillar_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/providers/brand_provider.dart';
import 'package:personal_branding_app/services/gemini_service.dart';
import 'package:personal_branding_app/widgets/ai_suggestion_box.dart';
import 'package:provider/provider.dart';

class ContentPillarScreen extends StatefulWidget {
  const ContentPillarScreen({super.key});

  @override
  State<ContentPillarScreen> createState() => _ContentPillarScreenState();
}

class _ContentPillarScreenState extends State<ContentPillarScreen> {
  final GeminiService _geminiService = GeminiService();

  Future<void> _getAIContentPillars() async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final brandIdentity = brandProvider.brand;

    if (brandIdentity.whoAreYou.isEmpty ||
        brandIdentity.mainSkill.isEmpty ||
        brandIdentity.passion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi data di tab "Jati Diri" terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    brandProvider.setLoading(true);

    final prompt = """
    Analisis identitas merek pribadi berikut:
    - Deskripsi Diri: ${brandIdentity.whoAreYou}
    - Keahlian Utama: ${brandIdentity.mainSkill}
    - Passion: ${brandIdentity.passion}
    - Nilai-nilai: ${brandIdentity.values}
    Berdasarkan analisis tersebut, buatkan 5 pilar konten utama yang paling relevan.
    Berikan jawaban dalam format daftar bernomor yang jelas dan ringkas.
    """;

    final result = await _geminiService.generateContent(prompt);
    brandProvider.setLoading(false);

    if (result != null && result.isNotEmpty) {
      final pillars = result
          .split('\n')
          .where((s) => s.isNotEmpty && s.contains(RegExp(r'^\d+\.')))
          .toList();
      brandProvider.setPillars(pillars);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan saran dari AI. Coba lagi nanti.'),
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
          '2. Tentukan Pilar Kontenmu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilar konten adalah 3-5 topik utama yang akan menjadi fokus kontenmu. Minta bantuan AI untuk menganalisis jati dirimu!',
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
          label: const Text("Minta Saran Pilar Konten dari AI", style: TextStyle(fontSize: 16)),
          onPressed: _getAIContentPillars,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        // Menggunakan AiSuggestionBox Widget
        Consumer<BrandProvider>(
          builder: (context, provider, child) {
            return AiSuggestionBox(
              title: 'Hasil Saran AI:',
              isLoading: provider.isLoading,
              suggestions: provider.contentPillars,
              emptyText: "Belum ada saran pilar konten.\nKlik tombol di atas untuk memulai!",
              icon: Icons.view_column_outlined,
            );
          },
        ),
      ],
    );
  }
}
