// lib/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Imports Interface (I_) ---
import 'package:personal_branding_app/core/services/i_ai_service.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:personal_branding_app/features/content_creation/domain/repositories/i_content_creation_repository.dart'; // File ini isinya IContentCreationRepository

// --- Imports Implementation (Impl) ---
import 'package:personal_branding_app/core/services/gemini_service.dart';
import 'package:personal_branding_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:personal_branding_app/features/content_creation/data/repositories/content_creation_repository.dart'; // File ini isinya ContentCreationRepositoryImpl

// ... imports auth ...
import 'package:personal_branding_app/features/auth/data/repositories/auth_repository.dart';


final getIt = GetIt.instance;

void setupServiceLocator() {
  // External
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Services
  getIt.registerLazySingleton<IAIService>(() => GeminiService(getIt<SupabaseClient>()));

  // Repositories - Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Repositories - Onboarding
  getIt.registerLazySingleton<IOnboardingRepository>(
    () => OnboardingRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<IAIService>(),
    ),
  );

  // Repositories - Content Creation (PERHATIKAN BAGIAN INI)
  // Ganti 'ContentCreationRepository' menjadi 'IContentCreationRepository'
  getIt.registerLazySingleton<IContentCreationRepository>(
    () => ContentCreationRepositoryImpl( // Gunakan nama kelas Implementasi
      getIt<SupabaseClient>(),
      getIt<IAIService>(),
    ),
  );
}