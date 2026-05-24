class BrandProfile {
  final String? selectedProfileName;
  final String? selectedCategory;
  final String? selectedMicroNiche;
  final String? selectedPremise;
  final String? toneOfVoice;
  final String targetAudience;

  // SWOT Analysis fields
  final String strengths;
  final String weaknesses;
  final String opportunities;
  final String threats;

  final List<String> monetizationOptions;
  final List<String> contentPillars;

  BrandProfile({
    this.selectedProfileName,
    this.selectedCategory,
    this.selectedMicroNiche,
    this.selectedPremise,
    this.toneOfVoice,
    this.targetAudience = '',
    this.strengths = '',
    this.weaknesses = '',
    this.opportunities = '',
    this.threats = '',
    this.monetizationOptions = const [],
    this.contentPillars = const [],
  });

  BrandProfile copyWith({
    String? selectedProfileName,
    String? selectedCategory,
    String? selectedMicroNiche,
    String? selectedPremise,
    String? toneOfVoice,
    String? targetAudience,
    String? strengths,
    String? weaknesses,
    String? opportunities,
    String? threats,
    List<String>? monetizationOptions,
    List<String>? contentPillars,
  }) {
    return BrandProfile(
      selectedProfileName: selectedProfileName ?? this.selectedProfileName,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMicroNiche: selectedMicroNiche ?? this.selectedMicroNiche,
      selectedPremise: selectedPremise ?? this.selectedPremise,
      toneOfVoice: toneOfVoice ?? this.toneOfVoice,
      targetAudience: targetAudience ?? this.targetAudience,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      opportunities: opportunities ?? this.opportunities,
      threats: threats ?? this.threats,
      monetizationOptions: monetizationOptions ?? this.monetizationOptions,
      contentPillars: contentPillars ?? this.contentPillars,
    );
  }

  factory BrandProfile.fromJson(Map<String, dynamic> json) {
    return BrandProfile(
      selectedProfileName: json['selected_profile_name'],
      selectedCategory: json['selected_category'],
      selectedMicroNiche: json['selected_micro_niche'],
      selectedPremise: json['selected_premise'],
      toneOfVoice: json['tone_of_voice'],
      targetAudience: json['target_audience'] ?? '',
      strengths: json['strengths'] ?? '',
      weaknesses: json['weaknesses'] ?? '',
      opportunities: json['opportunities'] ?? '',
      threats: json['threats'] ?? '',
      monetizationOptions:
          List<String>.from(json['monetization_options'] ?? []),
      contentPillars: List<String>.from(json['content_pillars'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_profile_name': selectedProfileName,
      'selected_category': selectedCategory,
      'selected_micro_niche': selectedMicroNiche,
      'selected_premise': selectedPremise,
      'tone_of_voice': toneOfVoice,
      'target_audience': targetAudience,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'opportunities': opportunities,
      'threats': threats,
      'monetization_options': monetizationOptions,
      'content_pillars': contentPillars,
    };
  }
}
