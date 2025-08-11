class ContentFactoryItem {
  final String id;
  String? selectedPillar;
  int ideaCount;
  bool isLoading;
  String? generatedIdeas;

  ContentFactoryItem({
    required this.id,
    this.selectedPillar,
    this.ideaCount = 5, // Default 5 ide
    this.isLoading = false,
    this.generatedIdeas,
  });
}