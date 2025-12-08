import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:personal_branding_app/core/services/i_ai_service.dart';

import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import '../../domain/repositories/i_onboarding_repository.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final SupabaseClient _supabase;
  final IAIService _aiService;

  OnboardingRepositoryImpl(this._supabase, this._aiService);

  @override
  Future<Result<UserProfile, Failure>> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        // Jika belum ada user auth, kembalikan profile kosong (New User)
        return Success(UserProfile());
      }

      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) {
        return Success(UserProfile());
      }
      return Success(UserProfile.fromJson(data));
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void, Failure>> saveUserProfile(UserProfile profile) async {
    try {
      var user = _supabase.auth.currentUser;
      if (user == null) {
        await _supabase.auth.signInAnonymously();
        user = _supabase.auth.currentUser;
      }
      
      if (user == null) throw DomainAuthException("Gagal membuat user sesi.");

      await _supabase.from('user_profiles').upsert({
        'user_id': user.id,
        ...profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<BrandProfile?, Failure>> getBrandProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return const Success(null);

      final data = await _supabase
          .from('brand_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) return const Success(null);

      return Success(BrandProfile.fromJson(data));
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void, Failure>> saveBrandProfile(BrandProfile profile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw DomainAuthException("No User found");

      await _supabase.from('brand_profiles').upsert({
        'user_id': user.id,
        ...profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  // --- AI GENERATION METHODS ---

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateIdentity(
      UserProfile profile, String languageCode) async {
    try {
      // 1. Save Profile First
      final saveResult = await saveUserProfile(profile);
      if (saveResult.isFailure) return ResultFailure(saveResult.failure);

      // 2. Prepare Payload
      final payload = {
        'fullName': profile.fullName,
        'whatILove': profile.whatILove,
        'whatImGoodAt': profile.whatImGoodAt,
        'whatTheWorldNeeds': profile.whatTheWorldNeeds,
        'whatICanBePaidFor': profile.whatICanBePaidFor,
      };

      // 3. Call AI Service
      final aiResult = await _aiService.processAI(
        action: 'generate_identity',
        payload: payload,
        languageCode: languageCode,
      );

      // 4. Parse Result
      return aiResult.map((data) {
        try {
          final resultString = data['result'] as String;
          return _parseIdentityResponse(resultString);
        } catch (e) {
          throw DataException("Gagal memproses saran identitas dari AI.");
        }
      });
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> generatePremise({
    required UserProfile userProfile,
    required BrandProfile brandProfile,
    required String strengths,
    required String weaknesses,
    required String opportunities,
    required String threats,
    required String languageCode,
  }) async {
    try {
      final payload = {
        'selectedProfileName': brandProfile.selectedProfileName,
        'selectedCategory': brandProfile.selectedCategory,
        'selectedMicroNiche': brandProfile.selectedMicroNiche,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'opportunities': opportunities,
        'threats': threats,
        'userStrengths': userProfile.whatImGoodAt,
      };

      final aiResult = await _aiService.processAI(
        action: 'generate_premise',
        payload: payload,
        languageCode: languageCode,
      );

      return aiResult.map((data) {
        try {
          final resultString = data['result'] as String;
          return _parsePremiseResponse(resultString);
        } catch (e) {
          throw DataException("Gagal memproses saran premise dari AI.");
        }
      });
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateContentPillars({
    required BrandProfile brandProfile,
    required String languageCode,
  }) async {
    try {
      await saveBrandProfile(brandProfile);

      final payload = {
        'selectedProfileName': brandProfile.selectedProfileName,
        'selectedCategory': brandProfile.selectedCategory,
        'selectedMicroNiche': brandProfile.selectedMicroNiche,
        'toneOfVoice': brandProfile.toneOfVoice,
        'targetAudience': brandProfile.targetAudience,
        'selectedPremise': brandProfile.selectedPremise,
      };

      final aiResult = await _aiService.processAI(
        action: 'generate_pillars',
        payload: payload,
        languageCode: languageCode,
      );

      return aiResult.map((data) {
        try {
          final resultString = data['result'] as String;
          return _parsePillarResponse(resultString);
        } catch (e) {
          throw DataException("Gagal memproses content pillar dari AI.");
        }
      });
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  // --- PRIVATE PARSING HELPERS (Diambil dari logika lama Anda) ---

  Map<String, dynamic> _parseIdentityResponse(String text) {
    String cleanText =
        text.replaceAll('```json', '').replaceAll('```', '').trim();
    final Map<String, dynamic> jsonData = json.decode(cleanText);

    final List<String> categories =
        List<String>.from(jsonData['categories'] ?? []);
    final List<String> microNiches =
        List<String>.from(jsonData['niches'] ?? []);
    final List<String> profileNames =
        List<String>.from(jsonData['profile_names'] ?? []);

    return {
      'aiResponse': text,
      'profileNames': profileNames,
      'categories': categories,
      'microNiches': microNiches,
      'opportunities': "Konsultasi, Produk Digital, Konten Sponsor, Membership, Workshop",
    };
  }

  Map<String, dynamic> _parsePremiseResponse(String text) {
    List<String> premiseOptions = [];
    final listStartRegex = RegExp(r'(\d+\.\s+.*)', dotAll: true);
    final listMatch = listStartRegex.firstMatch(text);

    if (listMatch != null) {
      final listContent = listMatch.group(0)!;
      final premiseBlocks = listContent.split(RegExp(r'\n\s*(?=\d+\.\s+)'));
      final quoteRegex = RegExp(r'"(.*?)"', dotAll: true);

      premiseOptions = premiseBlocks
          .map((block) {
            final quoteMatch = quoteRegex.firstMatch(block);
            if (quoteMatch != null) {
              return quoteMatch.group(1)?.trim();
            } else {
              final lines = block.split('\n');
              if (lines.length > 1) {
                return lines.sublist(1).join('\n').trim();
              }
            }
            return null;
          })
          .where((premise) => premise != null && premise.isNotEmpty)
          .cast<String>()
          .toList();
    }

    return {
      'aiResponse': text,
      'premiseOptions': premiseOptions,
    };
  }

  Map<String, dynamic> _parsePillarResponse(String text) {
    final pillarTitleRegex =
        RegExp(r"^\s*\d+\.\s*(.*?)(?=\n|$)", multiLine: true);
    final matches = pillarTitleRegex.allMatches(text);
    var contentPillarOptions = matches.map((m) => m.group(1)!.trim()).toList();
    
    if (contentPillarOptions.length > 4) {
      contentPillarOptions = contentPillarOptions.sublist(0, 4);
    }

    return {
      'aiResponse': text,
      'contentPillarOptions': contentPillarOptions,
    };
  }
} 