class ContentIdea {
  final String title;
  final String angle;
  final String contentOverview;
  final String viralPotential;
  final String insight;
  final String platform;

  ContentIdea({
    required this.title,
    required this.angle,
    required this.contentOverview,
    required this.viralPotential,
    required this.insight,
    this.platform = 'Multi-Platform',
  });

  factory ContentIdea.fromJson(Map<String, dynamic> json) {
    return ContentIdea(
      title: json['title'] ?? '',
      angle: json['angle'] ?? '',
      contentOverview: json['content_overview'] ?? '',
      viralPotential: json['viral_potential'] ?? '',
      insight: json['insight'] ?? '',
      platform: json['platform'] ?? 'Multi-Platform',
    );
  }
}

class ContentFactoryItem {
  final String id;
  String? selectedPillar;
  int ideaCount;
  bool isLoading;
  String? generatedIdeas; // Keep for backward compatibility or fallback
  List<ContentIdea>? ideas; // New structured data

  ContentFactoryItem({
    required this.id,
    this.selectedPillar,
    this.ideaCount = 5, // Default 5 ide
    this.isLoading = false,
    this.generatedIdeas,
    this.ideas,
  });
}
