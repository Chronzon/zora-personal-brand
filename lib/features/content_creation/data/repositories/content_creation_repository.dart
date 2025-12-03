import 'package:personal_branding_app/core/services/gemini_service.dart';
import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import '../models/content_factory_item.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_branding_app/features/content_creation/domain/repositories/content_creation_repository.dart';

class ContentCreationRepositoryImpl implements ContentCreationRepository {
  final GeminiService _geminiService;
  final SupabaseClient _supabase;

  ContentCreationRepositoryImpl(this._supabase, this._geminiService);

  @override
  Future<Map<String, dynamic>> generateContentIdeas({
    required String pillar,
    required int ideaCount,
    required BrandProfile brandProfile,
    required String languageCode,
  }) async {
    final payload = {
      'pillar': pillar,
      'ideaCount': ideaCount,
      'selectedProfileName': brandProfile.selectedProfileName,
      'selectedCategory': brandProfile.selectedCategory,
      'selectedMicroNiche': brandProfile.selectedMicroNiche,
      'toneOfVoice': brandProfile.toneOfVoice,
      'targetAudience': brandProfile.targetAudience,
    };

    try {
      final result = await _geminiService.generateContent(
          'generate_ideas', payload, languageCode);

      if (result != null) {
        // Try to parse as JSON
        final parsedIdeas = _parseResponse(result);

        // Save to Supabase if parsed successfully
        if (parsedIdeas != null) {
          await _saveIdeasToSupabase(parsedIdeas, pillar);
        }

        return {
          'rawResponse': result,
          'parsedIdeas': parsedIdeas,
        };
      } else {
        throw Exception('No response from AI service');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveIdeasToSupabase(
      List<ContentIdea> ideas, String pillar) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final List<Map<String, dynamic>> data = ideas.map((idea) {
      return {
        'user_id': user.id,
        'pillar': pillar,
        'title': idea.title,
        'angle': idea.angle,
        'content_overview': idea.contentOverview,
        'viral_potential': idea.viralPotential,
        'insight': idea.insight,
        'created_at': DateTime.now().toIso8601String(),
      };
    }).toList();

    await _supabase.from('content_ideas').insert(data);
  }

  List<ContentIdea>? _parseResponse(String text) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (jsonMatch == null) {
        return null;
      }

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((item) => ContentIdea.fromJson(item)).toList();
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }

  // 1. Simpan Script ke Database
  @override
  Future<void> saveGeneratedScript(GeneratedScript script) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = script.toJson();
    data['user_id'] = user.id; // Tambahkan user_id manual

    await _supabase.from('generated_scripts').insert(data);
  }

  // 2. Ambil Semua Script milik User
  @override
  Future<List<GeneratedScript>> getGeneratedScripts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('generated_scripts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      return (response as List)
          .map((item) => GeneratedScript.fromJson(item))
          .toList();
    } catch (e) {
      print("Error fetching scripts: $e");
      return [];
    }
  }

  // 3. Hapus Script
  @override
  Future<void> deleteGeneratedScript(String scriptId) async {
    await _supabase.from('generated_scripts').delete().eq('id', scriptId);
  }

  @override
  Future<String> generateScript({
    required ContentIdea idea,
    required String platform,
    required BrandProfile brandProfile,
    required String languageCode,
  }) async {
    final payload = {
      'idea': {
        'title': idea.title,
        'angle': idea.angle,
        'content_overview': idea.contentOverview,
      },
      'platform': platform,
      'selectedProfileName': brandProfile.selectedProfileName,
      'toneOfVoice': brandProfile.toneOfVoice,
      'targetAudience': brandProfile.targetAudience,
    };

    try {
      final result = await _geminiService.generateContent(
          'generate_script', payload, languageCode);

      if (result != null) {
        return result;
      } else {
        throw Exception('No response from AI service');
      }
    } catch (e) {
      rethrow;
    }
  }
}
