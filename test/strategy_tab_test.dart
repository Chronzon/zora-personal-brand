import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/features/dashboard/presentation/widgets/strategy_tab.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FakeStrategyRepository implements IOnboardingRepository {
  FakeStrategyRepository({
    required this.userProfile,
    required this.brandProfile,
  });

  final UserProfile userProfile;
  final BrandProfile brandProfile;

  @override
  Future<Result<UserProfile, Failure>> getUserProfile() async {
    return Success(userProfile);
  }

  @override
  Future<Result<BrandProfile?, Failure>> getBrandProfile() async {
    return Success(brandProfile);
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
  Future<Result<void, Failure>> saveOnboardingAnswer({
    required String onboardingStep,
    required Map<String, dynamic> selectedAnswer,
    required String source,
    String? modelProvider,
    String? modelName,
  }) async {
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> generateIdentity(
    UserProfile profile,
    String languageCode,
  ) async {
    return const Success({});
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
  testWidgets('mobile strategy shows opportunities and preserves stored input',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const indonesianMonetization = 'membantu UMKM membuat konten AI';
    const opportunities = 'Local founders need simple AI content workflows';

    final provider = OnboardingProvider(
      FakeStrategyRepository(
        userProfile: UserProfile(
          fullName: 'Alya Creator',
          whatILove: 'Teaching practical AI',
          whatImGoodAt: 'Turning strategy into simple content systems',
          whatTheWorldNeeds: 'Clearer AI workflows for founders',
          whatICanBePaidFor: indonesianMonetization,
        ),
        brandProfile: BrandProfile(
          selectedProfileName: 'Alya AI Studio',
          selectedCategory: 'Education',
          selectedMicroNiche: 'AI content workflows',
          selectedPremise: 'Practical AI for small teams',
          toneOfVoice: 'Educational & Informative',
          targetAudience: 'Solo founders',
          strengths: 'Clear teaching style',
          weaknesses: 'Inconsistent posting',
          opportunities: opportunities,
          threats: 'Crowded niche',
          monetizationOptions: const ['Paid workshops', 'Content audits'],
          contentPillars: const ['Education', 'Case studies'],
        ),
      ),
    );

    await provider.loadUserData();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: StrategyTab(),
        ),
      ),
    );

    expect(find.text('Opportunities'), findsOneWidget);
    expect(find.text(opportunities), findsOneWidget);
    expect(find.text('What I Can Be Paid For'), findsWidgets);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('AI suggestions'), findsOneWidget);
    expect(find.text(indonesianMonetization), findsWidgets);
    expect(find.text('Paid workshops'), findsOneWidget);
    expect(find.text('Content audits'), findsOneWidget);
  });

  testWidgets('monetization card shows blank user answer separately',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = OnboardingProvider(
      FakeStrategyRepository(
        userProfile: UserProfile(
          fullName: 'Alya Creator',
          whatILove: 'Teaching practical AI',
          whatImGoodAt: 'Turning strategy into simple content systems',
          whatTheWorldNeeds: 'Clearer AI workflows for founders',
        ),
        brandProfile: BrandProfile(
          selectedProfileName: 'Alya AI Studio',
          selectedCategory: 'Education',
          selectedMicroNiche: 'AI content workflows',
          selectedPremise: 'Practical AI for small teams',
          toneOfVoice: 'Educational & Informative',
          targetAudience: 'Solo founders',
          strengths: 'Clear teaching style',
          weaknesses: 'Inconsistent posting',
          opportunities: 'Local founders need simple AI content workflows',
          threats: 'Crowded niche',
          monetizationOptions: const ['Founder AI clinics', 'Workflow audits'],
          contentPillars: const ['Education', 'Case studies'],
        ),
      ),
    );

    await provider.loadUserData();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: StrategyTab(),
        ),
      ),
    );

    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Not set yet'), findsWidgets);
    expect(find.text('AI suggestions'), findsOneWidget);
    expect(find.text('Founder AI clinics'), findsOneWidget);
    expect(find.text('Workflow audits'), findsOneWidget);
  });
}
