import 'package:flutter_test/flutter_test.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';

class FakeOnboardingRepository implements IOnboardingRepository {
  FakeOnboardingRepository({
    UserProfile? userProfile,
    BrandProfile? brandProfile,
    Map<String, dynamic>? identityResponse,
  })  : _userProfile = userProfile ?? UserProfile(),
        _brandProfile = brandProfile,
        _identityResponse = identityResponse ?? const {};

  final UserProfile _userProfile;
  final BrandProfile? _brandProfile;
  final Map<String, dynamic> _identityResponse;

  @override
  Future<Result<UserProfile, Failure>> getUserProfile() async {
    return Success(_userProfile);
  }

  @override
  Future<Result<BrandProfile?, Failure>> getBrandProfile() async {
    return Success(_brandProfile);
  }

  @override
  Future<Result<void, Failure>> saveUserProfile(UserProfile profile) async {
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> saveBrandProfile(BrandProfile profile) async {
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateIdentity(
    UserProfile profile,
    String languageCode,
  ) async {
    return Success(_identityResponse);
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
    return const Success({});
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateContentPillars({
    required BrandProfile brandProfile,
    required String languageCode,
  }) async {
    return const Success({});
  }
}

void main() {
  test('empty loaded profile is notStarted and not complete', () async {
    final provider = OnboardingProvider(FakeOnboardingRepository());

    final isComplete = await provider.loadUserData();

    expect(isComplete, isFalse);
    expect(provider.hasStartedOnboarding, isFalse);
    expect(provider.isOnboardingComplete, isFalse);
    expect(provider.onboardingStatus, OnboardingStatus.notStarted);
  });

  test('partial loaded profile is inProgress and loadUserData returns false',
      () async {
    final provider = OnboardingProvider(
      FakeOnboardingRepository(
        userProfile: UserProfile(
          fullName: 'Alya',
          whatILove: 'Teaching AI',
        ),
      ),
    );

    final isComplete = await provider.loadUserData();

    expect(isComplete, isFalse);
    expect(provider.hasStartedOnboarding, isTrue);
    expect(provider.isOnboardingComplete, isFalse);
    expect(provider.onboardingStatus, OnboardingStatus.inProgress);
  });

  test('content pillars mark onboarding as completed', () async {
    final provider = OnboardingProvider(
      FakeOnboardingRepository(
        userProfile: UserProfile(fullName: 'Alya'),
        brandProfile: BrandProfile(
          contentPillars: const ['Education', 'Case studies'],
        ),
      ),
    );

    final isComplete = await provider.loadUserData();

    expect(isComplete, isTrue);
    expect(provider.contentPillarOptions, ['Education', 'Case studies']);
    expect(provider.isOnboardingComplete, isTrue);
    expect(provider.onboardingStatus, OnboardingStatus.completed);
  });

  test('brand profile parses monetization options from json', () {
    final profile = BrandProfile.fromJson({
      'monetization_options': ['Workshops', 'Content audits'],
      'content_pillars': ['Education'],
    });

    expect(profile.monetizationOptions, ['Workshops', 'Content audits']);
    expect(profile.toJson()['monetization_options'], [
      'Workshops',
      'Content audits',
    ]);
  });

  test('generateIdentity stores AI monetization without changing user answer',
      () async {
    final provider = OnboardingProvider(
      FakeOnboardingRepository(
        userProfile: UserProfile(whatICanBePaidFor: 'idk'),
        brandProfile: BrandProfile(opportunities: 'Existing opportunity'),
        identityResponse: const {
          'aiResponse': '{}',
          'profileNames': ['Alya AI Studio'],
          'categories': ['Education'],
          'microNiches': ['AI content workflows'],
          'monetizationOptions': ['Paid workshops', 'Content audits'],
        },
      ),
    );

    await provider.loadUserData();
    await provider.generateIdentity('en');

    expect(provider.userProfile.whatICanBePaidFor, 'idk');
    expect(provider.brandProfile.opportunities, 'Existing opportunity');
    expect(provider.brandProfile.monetizationOptions, [
      'Paid workshops',
      'Content audits',
    ]);
  });
}
