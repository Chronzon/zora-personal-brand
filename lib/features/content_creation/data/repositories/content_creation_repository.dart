import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:personal_branding_app/core/services/i_ai_service.dart'; // Gunakan Interface

import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/content_creation/data/models/content_factory_item.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import '../../domain/repositories/i_content_creation_repository.dart'; // Import Interface IContentCreationRepository

class ContentCreationRepositoryImpl implements IContentCreationRepository {
  final SupabaseClient _supabase;
  final IAIService _aiService; // Depend on Interface

  ContentCreationRepositoryImpl(this._supabase, this._aiService);

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateContentIdeas({
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
      // 1. Panggil AI Service
      final aiResult = await _aiService.processAI(
        action: 'generate_ideas',
        payload: payload,
        languageCode: languageCode,
      );

      // 2. Map hasilnya (Functional style)
      return await aiResult.mapAsync((data) async {
        final rawText = data['result'] as String;
        final parsedIdeas = _parseResponse(rawText);

        if (parsedIdeas != null) {
          // Simpan ke Supabase (Fire and forget, atau await jika kritis)
          await _saveIdeasToSupabase(parsedIdeas, pillar);
        }

        return {
          'rawResponse': rawText,
          'parsedIdeas': parsedIdeas ?? [],
        };
      });
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<String, Failure>> generateScript({
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
      final aiResult = await _aiService.processAI(
        action: 'generate_script',
        payload: payload,
        languageCode: languageCode,
      );

      return aiResult.map((data) => data['result'] as String);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  // --- CRUD Methods (Wrapped in Result) ---

  @override
  Future<Result<void, Failure>> saveGeneratedScript(GeneratedScript script) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw AuthException("User not found");

      final data = script.toJson();
      data['user_id'] = user.id;

      await _supabase.from('generated_scripts').insert(data);
      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<GeneratedScript>, Failure>> getGeneratedScripts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return const Success([]);

      final response = await _supabase
          .from('generated_scripts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final scripts = (response as List)
          .map((item) => GeneratedScript.fromJson(item))
          .toList();
      
      return Success(scripts);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void, Failure>> deleteGeneratedScript(String scriptId) async {
    try {
      await _supabase.from('generated_scripts').delete().eq('id', scriptId);
      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  // --- Helper Methods ---

  Future<void> _saveIdeasToSupabase(
      List<ContentIdea> ideas, String pillar) async {
    try {
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
    } catch (e) {
      print("Warning: Failed to save backup ideas: $e");
      // Tidak melempar error agar user tetap melihat hasil generate
    }
  }

  List<ContentIdea>? _parseResponse(String text) {
    try {
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanText);
      
      if (jsonMatch == null) return null;

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((item) => ContentIdea.fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }
}