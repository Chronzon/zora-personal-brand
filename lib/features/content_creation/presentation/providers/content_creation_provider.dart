import 'package:flutter/material.dart';
import '../../data/models/content_factory_item.dart';
import '../../data/models/generated_script.dart';
import '../../data/repositories/content_creation_repository.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/data/models/brand_profile.dart';
import 'package:uuid/uuid.dart';

class ContentCreationProvider extends ChangeNotifier {
  final ContentCreationRepository _repository;
  final OnboardingProvider _onboardingProvider;

  // Content factories state
  List<ContentFactoryItem> contentFactories = [];

  // Generated scripts state
  List<GeneratedScript> generatedScripts = [];
  bool isLoadingScripts = false;

  int _guestUsageCount = 0;
  static const int REMINDER_INTERVAL = 5; // Muncul setiap 5 kali

  // Getter: Cek apakah saatnya muncul popup?
  bool get shouldShowGuestReminder {
    // Muncul jika penggunaan > 0 DAN merupakan kelipatan 5 (5, 10, 15...)
    return _guestUsageCount > 0 && (_guestUsageCount % REMINDER_INTERVAL == 0);
  }

  void incrementGuestUsage() {
    _guestUsageCount++;
    // Tidak perlu notifyListeners() jika hanya untuk logika internal,
    // tapi boleh ditambahkan jika ingin menampilkan counter di UI.
  }

  ContentCreationProvider(this._repository, this._onboardingProvider) {
    // Initialize with one empty factory
    contentFactories.add(ContentFactoryItem(id: _generateId()));
  }

  String _generateId() {
    return const Uuid().v4();
  }

  Future<void> loadScripts() async {
    isLoadingScripts = true;
    // Jangan notifyListeners di sini jika dipanggil di splash screen bersamaan provider lain
    // untuk menghindari konflik build, tapi untuk case umum oke.

    try {
      final scripts = await _repository.getGeneratedScripts();
      generatedScripts = scripts;
    } catch (e) {
      print("Error loading scripts: $e");
    }

    isLoadingScripts = false;
    notifyListeners();
  }

  // Actions
  void addContentFactory() {
    contentFactories.add(ContentFactoryItem(id: _generateId()));
    notifyListeners();
  }

  Future<String?> addContentFactoryWithPillar(
      String pillar, int ideaCount) async {
    final newItem = ContentFactoryItem(
      id: _generateId(),
      selectedPillar: pillar,
      ideaCount: ideaCount,
      isLoading: true,
      generatedIdeas: null,
    );
    contentFactories.add(newItem);
    notifyListeners();
    return newItem.id;
  }

  void updateFactoryPillar(String id, String pillar) {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index != -1) {
      contentFactories[index].selectedPillar = pillar;
      notifyListeners();
    }
  }

  void updateFactoryIdeaCount(String id, int count) {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index != -1) {
      contentFactories[index].ideaCount = count;
      notifyListeners();
    }
  }

  Future<void> generateContentIdeas(String id, String languageCode) async {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final factory = contentFactories[index];
    factory.isLoading = true;
    notifyListeners();

    try {
      // Get brand profile from onboarding provider
      final BrandProfile brandProfile = _onboardingProvider.brandProfile;

      // Call repository to generate content ideas
      final result = await _repository.generateContentIdeas(
        pillar: factory.selectedPillar ?? '',
        ideaCount: factory.ideaCount,
        brandProfile: brandProfile,
        languageCode: languageCode,
      );

      // Update factory with results
      factory.generatedIdeas = result['rawResponse'];
      factory.ideas = result['parsedIdeas'];
    } catch (e) {
      factory.generatedIdeas = "Error: ${e.toString()}";
      factory.ideas = null;
    }

    factory.isLoading = false;
    notifyListeners();
  }

  Future<GeneratedScript?> generateScript(
      ContentIdea idea, String pillar, String languageCode) async {
    try {
      final BrandProfile brandProfile = _onboardingProvider.brandProfile;

      // 1. Generate text dari AI (Repo)
      final scriptText = await _repository.generateScript(
        idea: idea,
        platform: idea.platform,
        brandProfile: brandProfile,
        languageCode: languageCode,
      );

      // 2. Buat objek Script (Perhatikan ID sekarang UUID string dari generateId)
      final script = GeneratedScript(
        id: _generateId(), // Generate ID unik
        title: idea.title,
        platform: idea.platform,
        script: scriptText,
        createdAt: DateTime.now(),
        originalIdeaId: null,
        pillar: pillar,
      );

      // 3. Simpan ke Database Supabase
      await _repository.saveGeneratedScript(script);

      // 4. Update List Lokal
      generatedScripts.insert(0, script);
      notifyListeners();

      return script;
    } catch (e) {
      print("Error generating script: $e");
      return null;
    }
  }

  void deleteScript(String scriptId) async {
    // Hapus dari UI dulu agar cepat (Optimistic Update)
    generatedScripts.removeWhere((s) => s.id == scriptId);
    notifyListeners();

    // Hapus dari Database
    try {
      await _repository.deleteGeneratedScript(scriptId);
    } catch (e) {
      // Handle error jika perlu (misal balikin lagi ke list)
      print("Gagal menghapus dari DB");
    }
  }
}
