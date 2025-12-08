import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/features/content_creation/data/models/content_factory_item.dart';
import 'package:personal_branding_app/features/content_creation/data/models/generated_script.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';

abstract class IContentCreationRepository {
  Future<Result<Map<String, dynamic>, Failure>> generateContentIdeas({
    required String pillar,
    required int ideaCount,
    required BrandProfile brandProfile,
    required String languageCode,
  });

  Future<Result<void, Failure>> saveGeneratedScript(GeneratedScript script);

  Future<Result<List<GeneratedScript>, Failure>> getGeneratedScripts();

  Future<Result<void, Failure>> deleteGeneratedScript(String scriptId);

  Future<Result<String, Failure>> generateScript({
    required ContentIdea idea,
    required String platform,
    required BrandProfile brandProfile,
    required String languageCode,
  });
}