import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/brand_profile.dart';

abstract class IOnboardingRepository {
  Future<Result<UserProfile, Failure>> getUserProfile();

  Future<Result<void, Failure>> saveUserProfile(UserProfile profile);

  Future<Result<BrandProfile?, Failure>> getBrandProfile();

  Future<Result<void, Failure>> saveBrandProfile(BrandProfile profile);

  Future<Result<void, Failure>> saveOnboardingAnswer({
    required String onboardingStep,
    required Map<String, dynamic> selectedAnswer,
    required String source,
    String? modelProvider,
    String? modelName,
  });

  Future<Result<Map<String, dynamic>, Failure>> generateIdentity(
      UserProfile profile, String languageCode);

  Future<Result<Map<String, dynamic>, Failure>> generatePremise({
    required UserProfile userProfile,
    required BrandProfile brandProfile,
    required String strengths,
    required String weaknesses,
    required String opportunities,
    required String threats,
    required String languageCode,
  });

  Future<Result<Map<String, dynamic>, Failure>> generateContentPillars({
    required BrandProfile brandProfile,
    required String languageCode,
  });
}
