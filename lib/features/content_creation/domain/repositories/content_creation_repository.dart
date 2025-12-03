import 'package:personal_branding_app/features/content_creation/data/models/content_factory_item.dart';
import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';

abstract class ContentCreationRepository {
  Future<Map<String, dynamic>> generateContentIdeas({
    required String pillar,
    required int ideaCount,
    required BrandProfile brandProfile,
    required String languageCode,
  });

  Future<void> saveGeneratedScript(GeneratedScript script);

  Future<List<GeneratedScript>> getGeneratedScripts();

  Future<void> deleteGeneratedScript(String scriptId);

  Future<String> generateScript({
    required ContentIdea idea,
    required String platform,
    required BrandProfile brandProfile,
    required String languageCode,
  });
}
