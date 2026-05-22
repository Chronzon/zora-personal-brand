import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/features/onboarding/data/models/brand_profile.dart';
import 'package:personal_branding_app/features/onboarding/data/models/user_profile.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/identity_finder_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FakeIdentityRepository implements IOnboardingRepository {
  @override
  Future<Result<UserProfile, Failure>> getUserProfile() async {
    return Success(UserProfile());
  }

  @override
  Future<Result<BrandProfile?, Failure>> getBrandProfile() async {
    return const Success(null);
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
  testWidgets('identity step allows monetization to stay blank',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => OnboardingProvider(FakeIdentityRepository()),
          ),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: IdentityFinderScreen(),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(0), 'Teaching practical AI');
    await tester.enterText(fields.at(1), 'Simplifying strategy');
    await tester.enterText(fields.at(2), 'Clearer workflows for founders');
    await tester.pump();

    final continueButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(continueButton.onPressed, isNotNull);
  });
}
