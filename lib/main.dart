import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/core/theme/app_theme.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/content_creation/domain/repositories/i_content_creation_repository.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:personal_branding_app/core/di/service_locator.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/i_onboarding_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load the .env file
    await dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    setupServiceLocator();

    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider(
            create: (_) => OnboardingProvider(getIt<IOnboardingRepository>())),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProxyProvider<OnboardingProvider,
            ContentCreationProvider>(
          create: (context) => ContentCreationProvider(
            getIt<IContentCreationRepository>(),
            context.read<OnboardingProvider>(),
          ),
          update: (context, onboarding, previous) =>
              previous ??
              ContentCreationProvider(
                getIt<IContentCreationRepository>(),
                onboarding,
              ),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Personal Branding Builder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,

            // --- HUBUNGKAN PROVIDER KE SINI ---
            locale:
                localeProvider.locale, // Agar berubah saat user ganti bahasa
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
