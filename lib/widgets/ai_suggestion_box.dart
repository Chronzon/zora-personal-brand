// lib/widgets/ai_suggestion_box.dart

import 'package:flutter/material.dart';

class AiSuggestionBox extends StatelessWidget {
  final String title;
  final bool isLoading;
  final List<String> suggestions;
  final String emptyText;
  final IconData icon;

  const AiSuggestionBox({
    super.key,
    required this.title,
    required this.isLoading,
    required this.suggestions,
    required this.emptyText,
    this.icon = Icons.lightbulb_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (suggestions.isEmpty)
          Center(
            child: Text(
              emptyText,
              textAlign: TextAlign.center,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: suggestions
                .map((suggestion) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(icon, color: Colors.deepPurple),
                        title: Text(
                          suggestion.replaceAll(RegExp(r'^\d+\.\s*'), ''),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
