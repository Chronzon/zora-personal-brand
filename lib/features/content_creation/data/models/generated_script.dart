class GeneratedScript {
  final String id;
  final String title;
  final String platform;
  final String script;
  final DateTime createdAt;
  final String? originalIdeaId;
  final String pillar;

  GeneratedScript({
    required this.id,
    required this.title,
    required this.platform,
    required this.script,
    required this.createdAt,
    this.originalIdeaId,
    required this.pillar,
  });

  factory GeneratedScript.fromJson(Map<String, dynamic> json) {
    return GeneratedScript(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      platform: json['platform'] ?? 'Multi-Platform',
      script: json['script'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      originalIdeaId: json['original_idea_id']?.toString(),
      pillar: json['pillar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'script': script,
      'created_at': createdAt.toIso8601String(),
      'original_idea_id': originalIdeaId,
      'pillar': pillar,
    };
  }
}
