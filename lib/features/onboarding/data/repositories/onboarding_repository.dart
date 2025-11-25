import 'dart:convert';

import 'package:personal_branding_app/core/services/gemini_service.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  final GeminiService _geminiService;
  final SupabaseClient _supabase = Supabase.instance.client;

  OnboardingRepository(this._geminiService);

  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      await _supabase.auth.signInAnonymously();
    }

    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('user_profiles').upsert({
      'user_id': userId,
      'full_name': profile.fullName,
      'what_i_love': profile.whatILove,
      'what_im_good_at': profile.whatImGoodAt,
      'what_the_world_needs': profile.whatTheWorldNeeds,
      'what_i_can_be_paid_for': profile.whatICanBePaidFor,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Di dalam OnboardingRepository

  Future<void> saveBrandProfile(BrandProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // --- PERBAIKAN DI SINI ---
    await _supabase.from('brand_profiles').upsert(
      {
        'user_id': user.id,
        'selected_profile_name': profile.selectedProfileName,
        'selected_category': profile.selectedCategory,
        'selected_micro_niche': profile.selectedMicroNiche,
        'selected_premise': profile.selectedPremise,
        'tone_of_voice': profile.toneOfVoice,
        'target_audience': profile.targetAudience,
        'strengths': profile.strengths,
        'weaknesses': profile.weaknesses,
        'opportunities': profile.opportunities,
        'threats': profile.threats,
        'content_pillars': profile.contentPillars,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id', // <--- TAMBAHKAN BARIS INI PENTING!
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle(); // maybeSingle mengembalikan null jika tidak ada data

      if (data == null) return null;

      return UserProfile(
        fullName: data['full_name'] ?? '',
        whatILove: data['what_i_love'] ?? '',
        whatImGoodAt: data['what_im_good_at'] ?? '',
        whatTheWorldNeeds: data['what_the_world_needs'] ?? '',
        whatICanBePaidFor: data['what_i_can_be_paid_for'] ?? '',
      );
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

// Ambil data Brand Profile
  Future<BrandProfile?> getBrandProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('brand_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) return null;

      return BrandProfile(
        selectedProfileName: data['selected_profile_name'],
        selectedCategory: data['selected_category'],
        selectedMicroNiche: data['selected_micro_niche'],
        selectedPremise: data['selected_premise'],
        toneOfVoice: data['tone_of_voice'],
        targetAudience: data['target_audience'] ?? '',
        strengths: data['strengths'] ?? '',
        weaknesses: data['weaknesses'] ?? '',
        opportunities: data['opportunities'] ?? '',
        contentPillars: List<String>.from(data['content_pillars'] ?? []),
        threats: data['threats'] ?? '',
      );
    } catch (e) {
      print("Error fetching brand profile: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> generateIdentity(UserProfile profile, String languageCode) async {
    await saveUserProfile(profile);

    final payload = {
      'fullName': profile.fullName,
      'whatILove': profile.whatILove,
      'whatImGoodAt': profile.whatImGoodAt,
      'whatTheWorldNeeds': profile.whatTheWorldNeeds,
      'whatICanBePaidFor': profile.whatICanBePaidFor,
    };

    final result =
        await _geminiService.generateContent('generate_identity', payload, languageCode);
    if (result == null || result.isEmpty) {
      throw Exception("Gagal mendapatkan respons dari AI.");
    }

    return _parseIdentityResponse(result);
  }

  Map<String, dynamic> _parseIdentityResponse(String text) {
    try {
      String cleanText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> jsonData = json.decode(cleanText);

      final List<String> categories =
          List<String>.from(jsonData['categories'] ?? []);
      final List<String> microNiches =
          List<String>.from(jsonData['niches'] ?? []);
      final List<String> profileNames =
          List<String>.from(jsonData['profile_names'] ?? []);

      String monetizationText =
          "Konsultasi, Produk Digital, Konten Sponsor, Membership, Workshop";

      return {
        'aiResponse': text,
        'profileNames': profileNames,
        'categories': categories,
        'microNiches': microNiches,
        'opportunities': monetizationText,
      };
    } catch (e) {
      print("Error parsing JSON: $e");
      throw Exception("Gagal memproses saran dari AI. Coba lagi.");
    }
  }

  Future<Map<String, dynamic>> generatePremise({
    required UserProfile userProfile,
    required BrandProfile brandProfile,
    required String strengths,
    required String weaknesses,
    required String opportunities,
    required String threats,
    required String languageCode,
  }) async {
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

    final result =
        await _geminiService.generateContent('generate_premise', payload, languageCode);
    if (result == null || result.isEmpty) {
      throw Exception("Gagal mendapatkan respons dari AI.");
    }

    return _parsePremiseResponse(result);
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

  Future<Map<String, dynamic>> generateContentPillars({
    required BrandProfile brandProfile,
    required String languageCode,
  }) async {
    await saveBrandProfile(brandProfile);

    final payload = {
      'selectedProfileName': brandProfile.selectedProfileName,
      'selectedCategory': brandProfile.selectedCategory,
      'selectedMicroNiche': brandProfile.selectedMicroNiche,
      'toneOfVoice': brandProfile.toneOfVoice,
      'targetAudience': brandProfile.targetAudience,
      'selectedPremise': brandProfile.selectedPremise,
    };

    final result =
        await _geminiService.generateContent('generate_pillars', payload, languageCode);
    if (result == null || result.isEmpty) {
      throw Exception("Gagal mendapatkan respons dari AI.");
    }

    return _parsePillarResponse(result);
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
