import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';

abstract class OnboardingRepository {
  Future<void> saveUserProfile(UserProfile profile);

  Future<void> saveBrandProfile(BrandProfile profile);

  Future<UserProfile?> getUserProfile();

  Future<BrandProfile?> getBrandProfile();

  Future<Map<String, dynamic>> generateIdentity(
      UserProfile profile, String languageCode);

  Future<Map<String, dynamic>> generatePremise({
    required UserProfile userProfile,
    required BrandProfile brandProfile,
    required String strengths,
    required String weaknesses,
    required String opportunities,
    required String threats,
    required String languageCode,
  });

  Future<Map<String, dynamic>> generateContentPillars({
    required BrandProfile brandProfile,
    required String languageCode,
  });
}
