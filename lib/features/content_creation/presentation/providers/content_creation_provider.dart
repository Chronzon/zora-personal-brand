import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/errors/failures.dart'; // Import Failure
import 'package:personal_branding_app/features/content_creation/data/models/content_factory_item.dart';
import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/content_creation/domain/repositories/i_content_creation_repository.dart'; // Gunakan Interface
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:uuid/uuid.dart';

class ContentCreationProvider extends ChangeNotifier {
  // Gunakan Interface Repository
  final IContentCreationRepository _repository;
  final OnboardingProvider _onboardingProvider;

  // Content factories state
  List<ContentFactoryItem> contentFactories = [];

  // Generated scripts state
  List<GeneratedScript> generatedScripts = [];
  bool isLoadingScripts = false;
  Failure? _failure; // Menyimpan error state

  int _guestUsageCount = 0;
  static const int REMINDER_INTERVAL = 5;

  // Getter
  Failure? get failure => _failure;

  bool get shouldShowGuestReminder {
    return _guestUsageCount > 0 && (_guestUsageCount % REMINDER_INTERVAL == 0);
  }

  void incrementGuestUsage() {
    _guestUsageCount++;
  }

  ContentCreationProvider(this._repository, this._onboardingProvider) {
    contentFactories.add(ContentFactoryItem(id: _generateId()));
  }

  String _generateId() {
    return const Uuid().v4();
  }

  // --- REFACTORED: loadScripts ---
  Future<void> loadScripts() async {
    isLoadingScripts = true;
    _failure = null;
    // Hindari notifyListeners di sini jika dipanggil saat init app
    
    final result = await _repository.getGeneratedScripts();

    // Buka bungkusan Result
    result.fold(
      onSuccess: (scripts) {
        generatedScripts = scripts;
      },
      onFailure: (f) {
        _failure = f;
        print("Error loading scripts: ${f.message}");
      },
    );

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

  // --- REFACTORED: generateContentIdeas ---
  Future<void> generateContentIdeas(String id, String languageCode) async {
    final index = contentFactories.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final factory = contentFactories[index];
    factory.isLoading = true;
    factory.generatedIdeas = null; // Reset error sebelumnya
    notifyListeners();

    final BrandProfile brandProfile = _onboardingProvider.brandProfile;

    final result = await _repository.generateContentIdeas(
      pillar: factory.selectedPillar ?? '',
      ideaCount: factory.ideaCount,
      brandProfile: brandProfile,
      languageCode: languageCode,
    );

    // Buka bungkusan Result
    result.fold(
      onSuccess: (data) {
        factory.generatedIdeas = data['rawResponse'];
        factory.ideas = data['parsedIdeas'];
      },
      onFailure: (f) {
        factory.generatedIdeas = "Error: ${f.message}";
        factory.ideas = null;
      },
    );

    factory.isLoading = false;
    notifyListeners();
  }

  // --- REFACTORED: generateScript ---
  Future<GeneratedScript?> generateScript(
      ContentIdea idea, String pillar, String languageCode) async {
    
    final BrandProfile brandProfile = _onboardingProvider.brandProfile;
    GeneratedScript? resultScript;

    // 1. Generate text dari AI (Repo mengembalikan Result<String, Failure>)
    final result = await _repository.generateScript(
      idea: idea,
      platform: idea.platform,
      brandProfile: brandProfile,
      languageCode: languageCode,
    );

    // Kita gunakan foldAsync karena di dalam success kita melakukan operasi async (save DB)
    await result.foldAsync(
      onSuccess: (scriptText) async {
        // 2. Buat objek Script
        final script = GeneratedScript(
          id: _generateId(),
          title: idea.title,
          platform: idea.platform,
          script: scriptText,
          createdAt: DateTime.now(),
          originalIdeaId: null,
          pillar: pillar,
        );

        // 3. Simpan ke Database
        final saveResult = await _repository.saveGeneratedScript(script);

        if (saveResult.isSuccess) {
          generatedScripts.insert(0, script);
          resultScript = script;
        } else {
          // Handle jika gagal save (misal koneksi putus saat save)
          print("Failed to save script: ${saveResult.failure.message}");
          _failure = saveResult.failure;
        }
      },
      onFailure: (f) async {
        print("Error generating script AI: ${f.message}");
        _failure = f;
      },
    );

    notifyListeners();
    return resultScript;
  }

  // --- REFACTORED: deleteScript ---
  void deleteScript(String scriptId) async {
    // 1. Hapus dari UI dulu agar cepat (Optimistic Update)
    final index = generatedScripts.indexWhere((s) => s.id == scriptId);
    if (index == -1) return;

    final deletedScript = generatedScripts[index];
    generatedScripts.removeAt(index);
    notifyListeners();

    // 2. Hapus dari Database
    final result = await _repository.deleteGeneratedScript(scriptId);

    // 3. Jika Gagal, Kembalikan data (Rollback)
    if (result.isFailure) {
      print("Gagal menghapus dari DB: ${result.failure.message}");
      generatedScripts.insert(index, deletedScript);
      notifyListeners();
      
      // Opsional: Set global failure untuk menampilkan snackbar di UI
      _failure = result.failure;
      notifyListeners();
    }
  }
}