import 'dart:io';
import 'package:flutter/material.dart';

import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository;

  // State
  UserProfile _userProfile = UserProfile();
  BrandProfile _brandProfile = BrandProfile();
  File? profileImage;

  // AI State
  bool isLoading = false;
  String? aiResponse;
  String? errorMessage;

  // Options
  List<String> profileNameOptions = [];
  List<String> categoryOptions = [];
  List<String> microNicheOptions = [];
  List<String> premiseOptions = [];
  List<String> contentPillarOptions = [];

  // SWOT fields now in BrandProfile model
  String? premiseAiResponse;
  String? pillarAiResponse;

  OnboardingProvider(this._repository);

  // Getters
  UserProfile get userProfile => _userProfile;
  BrandProfile get brandProfile => _brandProfile;

  // Setters for UserProfile
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
    profileImage = image;
    notifyListeners();
  }

  // Setters for BrandProfile
  set selectedProfileName(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedProfileName: value);
    notifyListeners();
  }

  set selectedCategory(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedCategory: value);
    notifyListeners();
  }

  set selectedMicroNiche(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedMicroNiche: value);
    notifyListeners();
  }

  set selectedPremise(String? value) {
    _brandProfile = _brandProfile.copyWith(selectedPremise: value);
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

  // SWOT setters
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

  Future<bool> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final userProfileData = await _repository.getUserProfile();
      final brandProfileData = await _repository.getBrandProfile();

      if (userProfileData != null) {
        _userProfile = userProfileData;
      }

      if (brandProfileData != null) {
        _brandProfile = brandProfileData;
        if (_brandProfile.contentPillars.isNotEmpty) {
          contentPillarOptions = _brandProfile.contentPillars;
        }
      }

      isLoading = false;
      notifyListeners();

      return userProfileData != null && userProfileData.whatILove.isNotEmpty;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actions
  Future<void> generateIdentity(String languageCode) async {
    isLoading = true;
    errorMessage = null;
    aiResponse = null;
    notifyListeners();

    try {
      final result =
          await _repository.generateIdentity(_userProfile, languageCode);
      aiResponse = result['aiResponse'];
      profileNameOptions = List<String>.from(result['profileNames']);
      categoryOptions = List<String>.from(result['categories']);
      microNicheOptions = List<String>.from(result['microNiches']);
      // Store opportunities in BrandProfile
      _brandProfile = _brandProfile.copyWith(
        opportunities: result['opportunities'],
      );
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> generatePremise(String languageCode) async {
    isLoading = true;
    errorMessage = null;
    premiseAiResponse = null;
    notifyListeners();

    try {
      final result = await _repository.generatePremise(
        userProfile: _userProfile,
        brandProfile: _brandProfile,
        strengths: _brandProfile.strengths,
        weaknesses: _brandProfile.weaknesses,
        opportunities: _brandProfile.opportunities,
        threats: _brandProfile.threats,
        languageCode: languageCode,
      );
      premiseAiResponse = result['aiResponse'];
      premiseOptions = List<String>.from(result['premiseOptions']);
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> generateContentPillars(String languageCode) async {
    isLoading = true;
    errorMessage = null;
    pillarAiResponse = null;
    notifyListeners();

    try {
      final result = await _repository.generateContentPillars(
        brandProfile: _brandProfile,
        languageCode: languageCode,
      );
      pillarAiResponse = result['aiResponse'];
      contentPillarOptions = List<String>.from(result['contentPillarOptions']);
      // 1. Update state brand profile dengan pilar baru
      _brandProfile = _brandProfile.copyWith(
        contentPillars: contentPillarOptions,
      );

      // 2. Simpan permanen ke Supabase
      await _repository.saveBrandProfile(_brandProfile);
    } catch (e) {
      errorMessage = "Terjadi kesalahan: ${e.toString()}";
      // Tambahkan ini agar UI tahu kalau ada yang salah, meskipun AI sukses
      print("ERROR SAVE DB: $e");
      // Opsional: Kosongkan response agar UI tidak navigasi (jika ingin ketat)
      // pillarAiResponse = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
