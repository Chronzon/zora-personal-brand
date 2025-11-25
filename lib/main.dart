import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personal_branding_app/core/providers/locale_provider.dart';
import 'package:personal_branding_app/core/services/gemini_service.dart';
import 'package:personal_branding_app/core/theme/app_theme.dart';
import 'package:personal_branding_app/features/auth/data/repositories/auth_repository.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/content_creation/data/repositories/content_creation_repository.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

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
          create: (_) => AuthProvider(AuthRepository()),
        ),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProxyProvider<OnboardingProvider,
            ContentCreationProvider>(
          create: (context) => ContentCreationProvider(
            ContentCreationRepository(GeminiService()),
            context.read<OnboardingProvider>(),
          ),
          update: (context, onboarding, previous) =>
              previous ??
              ContentCreationProvider(
                ContentCreationRepository(GeminiService()),
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
            locale: localeProvider.locale, // Agar berubah saat user ganti bahasa
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
