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
      contentPillars: contentPillars ?? this.contentPillars,
    );
  }
}
