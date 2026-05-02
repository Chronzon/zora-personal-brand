import 'dart:convert';
import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'package:personal_branding_app/core/services/i_ai_service.dart'; // Gunakan Interface

import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/content_creation/data/models/content_factory_item.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import '../../domain/repositories/i_content_creation_repository.dart'; // Import Interface IContentCreationRepository

class ContentCreationRepositoryImpl implements IContentCreationRepository {
  final ApiClient _apiClient;
  final IAIService _aiService; // Depend on Interface

  ContentCreationRepositoryImpl(this._apiClient, this._aiService);

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
          await _saveIdeasToBackend(parsedIdeas, pillar);
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
  Future<Result<void, Failure>> saveGeneratedScript(
      GeneratedScript script) async {
    try {
      await _apiClient.ensureGuestSession();
      final data = script.toJson()
        ..remove('id')
        ..remove('created_at');
      await _apiClient.post('/generated-scripts', body: data);
      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<GeneratedScript>, Failure>> getGeneratedScripts() async {
    try {
      if (!_apiClient.isAuthenticated) return const Success([]);

      final response = await _apiClient.get('/generated-scripts');
      final data = response['data'] as List? ?? [];

      final scripts =
          data.map((item) => GeneratedScript.fromJson(item)).toList();

      return Success(scripts);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void, Failure>> deleteGeneratedScript(String scriptId) async {
    try {
      await _apiClient.delete('/generated-scripts/$scriptId');
      return const Success(null);
    } catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    }
  }

  // --- Helper Methods ---

  Future<void> _saveIdeasToBackend(
      List<ContentIdea> ideas, String pillar) async {
    try {
      final List<Map<String, dynamic>> data = ideas.map((idea) {
        return {
          'title': idea.title,
          'angle': idea.angle,
          'content_overview': idea.contentOverview,
          'viral_potential': idea.viralPotential,
          'insight': idea.insight,
          'platform': idea.platform,
        };
      }).toList();

      await _apiClient.post('/content-ideas', body: {
        'pillar': pillar,
        'ideas': data,
      });
    } catch (e) {
      print("Warning: Failed to save backup ideas: $e");
      // Tidak melempar error agar user tetap melihat hasil generate
    }
  }

  List<ContentIdea>? _parseResponse(String text) {
    try {
      String cleanText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
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
