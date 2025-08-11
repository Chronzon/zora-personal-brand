// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:personal_branding_app/models/content_factory_item.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${provider.fullName}!'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        // Tambah 1 item untuk tombol 'add'
        itemCount: provider.contentFactories.length + 1,
        itemBuilder: (context, index) {
          // Jika ini adalah item terakhir, tampilkan tombol 'add'
          if (index == provider.contentFactories.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: FloatingActionButton.small(
                  onPressed: () => provider.addContentFactory(),
                  child: const Icon(Icons.add),
                ),
              ),
            );
          }
          // Jika tidak, tampilkan ContentFactoryWidget
          return ContentFactoryWidget(
            factoryItem: provider.contentFactories[index],
          );
        },
      ),
    );
  }
}

class ContentFactoryWidget extends StatefulWidget {
  final ContentFactoryItem factoryItem;
  const ContentFactoryWidget({super.key, required this.factoryItem});

  @override
  State<ContentFactoryWidget> createState() => _ContentFactoryWidgetState();
}

class _ContentFactoryWidgetState extends State<ContentFactoryWidget> {
  // --- FUNGSI DIALOG YANG DIPERBARUI ---
  void _showResultDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Mendapatkan lebar layar untuk membatasi lebar dialog
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: const Text('Generated Content Ideas'),
          // Memberi batasan lebar pada konten agar tidak overflow
          content: SizedBox(
            width: screenWidth * 0.9, // Gunakan 90% dari lebar layar
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: content,
                selectable: true,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    final pillarOptions = provider.contentPillarOptions;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Judul di tengah
            const Center(
              child: Text(
                'CONTENT FACTORY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ),
            const SizedBox(height: 16),

            // Row 2: Dua kolom
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom 1: Dropdown Content Pillar
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.factoryItem.selectedPillar,
                    items: pillarOptions.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateFactoryPillar(widget.factoryItem.id, value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Content Pillar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Kolom 2: Field Jumlah Ide
                Expanded(
                  child: TextFormField(
                    initialValue: widget.factoryItem.ideaCount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Ide',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final count = int.tryParse(value) ?? 5;
                      provider.updateFactoryIdeaCount(widget.factoryItem.id, count);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 3: Tombol Generate
            if (widget.factoryItem.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.factoryItem.generatedIdeas != null) {
                      _showResultDialog(context, widget.factoryItem.generatedIdeas!);
                    } else if (widget.factoryItem.selectedPillar != null) {
                      provider.generateContentIdeas(widget.factoryItem.id);
                    }
                  },
                  child: Text(widget.factoryItem.generatedIdeas != null ? 'Open' : 'Generate'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
