import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:personal_branding_app/core/network/api_client.dart';
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

      if (aiResult.isFailure) {
        return ResultFailure(aiResult.failure);
      }

      final rawText = aiResult.success['result'] as String? ?? '';
      final parsedIdeas = _parseResponse(rawText);

      if (parsedIdeas == null || parsedIdeas.isEmpty) {
        throw DataException(
          'AI returned ideas in an unexpected format. Please try again.',
          code: 'INVALID_AI_IDEAS',
        );
      }

      await _saveIdeasToBackend(parsedIdeas, pillar);

      return Success({
        'rawResponse': rawText,
        'parsedIdeas': parsedIdeas,
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

      final scripts = data
          .whereType<Map<String, dynamic>>()
          .map(GeneratedScript.fromJson)
          .toList();

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
      debugPrint("Warning: Failed to save backup ideas: $e");
      // Tidak melempar error agar user tetap melihat hasil generate
    }
  }

  List<ContentIdea>? _parseResponse(String text) {
    try {
      final cleanText = text
          .replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      final decoded = _decodeIdeasPayload(cleanText);
      if (decoded == null) return null;

      final jsonList = switch (decoded) {
        List<dynamic> list => list,
        Map<String, dynamic> map when map['ideas'] is List<dynamic> =>
          map['ideas'] as List<dynamic>,
        Map<String, dynamic> map when map['data'] is List<dynamic> =>
          map['data'] as List<dynamic>,
        Map<String, dynamic> map when map['content_ideas'] is List<dynamic> =>
          map['content_ideas'] as List<dynamic>,
        _ => null,
      };

      if (jsonList == null) return null;

      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(ContentIdea.fromJson)
          .where((idea) => idea.title.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return null;
    }
  }

  dynamic _decodeIdeasPayload(String text) {
    try {
      return json.decode(text);
    } on FormatException {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text) ??
          RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) return null;
      return json.decode(jsonMatch.group(0)!);
    }
  }
}
