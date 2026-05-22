import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import '../../domain/repositories/i_onboarding_repository.dart'; // Import Interface

enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
}

class OnboardingProvider extends ChangeNotifier {
  // Gunakan Interface, bukan Concrete Implementation
  final IOnboardingRepository _repository;

  // --- STATE (Encapsulated) ---
  UserProfile _userProfile = UserProfile();
  BrandProfile _brandProfile = BrandProfile();
  File? _profileImage;

  bool _isLoading = false;
  Failure? _failure; // Simpan Failure object, bukan sekadar String error

  // --- OPTIONS STATE ---
  List<String> _profileNameOptions = [];
  List<String> _categoryOptions = [];
  List<String> _microNicheOptions = [];
  List<String> _premiseOptions = [];
  List<String> _contentPillarOptions = [];

  String? _aiResponse;
  String? _premiseAiResponse;
  String? _pillarAiResponse;

  OnboardingProvider(this._repository);

  // --- GETTERS (Public access to state) ---
  UserProfile get userProfile => _userProfile;
  BrandProfile get brandProfile => _brandProfile;
  File? get profileImage => _profileImage;

  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get errorMessage => _failure?.message; // Helper for UI compatibility

  List<String> get profileNameOptions => List.unmodifiable(_profileNameOptions);
  List<String> get categoryOptions => List.unmodifiable(_categoryOptions);
  List<String> get microNicheOptions => List.unmodifiable(_microNicheOptions);
  List<String> get premiseOptions => List.unmodifiable(_premiseOptions);
  List<String> get contentPillarOptions =>
      List.unmodifiable(_contentPillarOptions);

  String? get aiResponse => _aiResponse;
  String? get premiseAiResponse => _premiseAiResponse;
  String? get pillarAiResponse => _pillarAiResponse;

  bool get isOnboardingComplete => _brandProfile.contentPillars.isNotEmpty;

  bool get hasStartedOnboarding {
    final hasUserData = _userProfile.fullName.trim().isNotEmpty ||
        _userProfile.whatILove.trim().isNotEmpty ||
        _userProfile.whatImGoodAt.trim().isNotEmpty ||
        _userProfile.whatTheWorldNeeds.trim().isNotEmpty ||
        _userProfile.whatICanBePaidFor.trim().isNotEmpty;

    final hasBrandData =
        (_brandProfile.selectedProfileName?.trim().isNotEmpty ?? false) ||
            (_brandProfile.selectedCategory?.trim().isNotEmpty ?? false) ||
            (_brandProfile.selectedMicroNiche?.trim().isNotEmpty ?? false) ||
            (_brandProfile.selectedPremise?.trim().isNotEmpty ?? false) ||
            (_brandProfile.toneOfVoice?.trim().isNotEmpty ?? false) ||
            _brandProfile.targetAudience.trim().isNotEmpty ||
            _brandProfile.strengths.trim().isNotEmpty ||
            _brandProfile.weaknesses.trim().isNotEmpty ||
            _brandProfile.opportunities.trim().isNotEmpty ||
            _brandProfile.threats.trim().isNotEmpty ||
            _brandProfile.contentPillars.isNotEmpty;

    return hasUserData || hasBrandData;
  }

  OnboardingStatus get onboardingStatus {
    if (isOnboardingComplete) return OnboardingStatus.completed;
    if (hasStartedOnboarding) return OnboardingStatus.inProgress;
    return OnboardingStatus.notStarted;
  }

  // --- SETTERS (With Validation Logic if needed) ---
  void updateFullName(String name) {
    _userProfile = _userProfile.copyWith(fullName: name);
    notifyListeners();
  }

  set whatILove(String value) {
    _userProfile = _userProfile.copyWith(whatILove: value);
    notifyListeners();
  }

  set whatImGoodAt(String value) {
    _userProfile = _userProfile.copyWith(whatImGoodAt: value);
    notifyListeners();
  }

  set whatTheWorldNeeds(String value) {
    _userProfile = _userProfile.copyWith(whatTheWorldNeeds: value);
    notifyListeners();
  }

  set whatICanBePaidFor(String value) {
    _userProfile = _userProfile.copyWith(whatICanBePaidFor: value);
    notifyListeners();
  }

  void setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }

  // Setter helpers for Brand Profile (similar pattern...)
  set selectedProfileName(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedProfileName: value);
    notifyListeners();
  }

  // ... (Implement other setters: selectedCategory, selectedMicroNiche, etc. using copyWith) ...
  set selectedCategory(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedCategory: value);
    notifyListeners();
  }

  set selectedMicroNiche(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedMicroNiche: value);
    notifyListeners();
  }

  set strengths(String value) {
    _brandProfile = _brandProfile.copyWith(strengths: value);
    notifyListeners();
  }

  set weaknesses(String value) {
    _brandProfile = _brandProfile.copyWith(weaknesses: value);
    notifyListeners();
  }

  set opportunities(String value) {
    _brandProfile = _brandProfile.copyWith(opportunities: value);
    notifyListeners();
  }

  set threats(String value) {
    _brandProfile = _brandProfile.copyWith(threats: value);
    notifyListeners();
  }

  set toneOfVoice(String? value) {
    _brandProfile = _brandProfile.copyWith(toneOfVoice: value);
    notifyListeners();
  }

  set targetAudience(String value) {
    _brandProfile = _brandProfile.copyWith(targetAudience: value);
    notifyListeners();
  }

  set selectedPremise(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedPremise: value);
    notifyListeners();
  }

  // --- ACTIONS (Async with Result Handling) ---

  Future<bool> loadUserData() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final userResult = await _repository.getUserProfile();
    final brandResult = await _repository.getBrandProfile();

    _isLoading = false;

    // Handle User Profile Result
    userResult.fold(
      onSuccess: (data) => _userProfile = data,
      onFailure: (f) => _failure = f, // Non-blocking failure usually for load
    );

    // Handle Brand Profile Result
    brandResult.fold(
      onSuccess: (data) {
        if (data != null) {
          _brandProfile = data;
          _contentPillarOptions = List.from(data.contentPillars);
        } else {
          _brandProfile = BrandProfile();
          _contentPillarOptions = [];
        }
      },
      onFailure: (f) => _failure = f,
    );

    notifyListeners();
    return isOnboardingComplete;
  }

  Future<void> generateIdentity(String languageCode) async {
    _isLoading = true;
    _failure = null;
    _aiResponse = null;
    notifyListeners();

    final result =
        await _repository.generateIdentity(_userProfile, languageCode);

    result.fold(
      onSuccess: (data) {
        _aiResponse = data['aiResponse'];
        _profileNameOptions = List<String>.from(data['profileNames']);
        _categoryOptions = List<String>.from(data['categories']);
        _microNicheOptions = List<String>.from(data['microNiches']);

        _brandProfile =
            _brandProfile.copyWith(opportunities: data['opportunities']);
      },
      onFailure: (f) {
        _failure = f;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generatePremise(String languageCode) async {
    _isLoading = true;
    _failure = null;
    _premiseAiResponse = null;
    notifyListeners();

    final result = await _repository.generatePremise(
      userProfile: _userProfile,
      brandProfile: _brandProfile,
      strengths: _brandProfile.strengths,
      weaknesses: _brandProfile.weaknesses,
      opportunities: _brandProfile.opportunities,
      threats: _brandProfile.threats,
      languageCode: languageCode,
    );

    result.fold(
      onSuccess: (data) {
        _premiseAiResponse = data['aiResponse'];
        _premiseOptions = List<String>.from(data['premiseOptions']);
      },
      onFailure: (f) => _failure = f,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateContentPillars(String languageCode) async {
    _isLoading = true;
    _failure = null;
    _pillarAiResponse = null;
    notifyListeners();

    final result = await _repository.generateContentPillars(
      brandProfile: _brandProfile,
      languageCode: languageCode,
    );

    await result.foldAsync(
      onSuccess: (data) async {
        _pillarAiResponse = data['aiResponse'];
        _contentPillarOptions = List<String>.from(data['contentPillarOptions']);

        _brandProfile =
            _brandProfile.copyWith(contentPillars: _contentPillarOptions);

        // Save automatically
        final saveResult = await _repository.saveBrandProfile(_brandProfile);
        if (saveResult.isFailure) {
          _failure = saveResult.failure;
        }
      },
      onFailure: (f) async => _failure = f,
    );

    _isLoading = false;
    notifyListeners();
  }
}
