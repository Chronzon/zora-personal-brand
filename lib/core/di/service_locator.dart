import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:personal_branding_app/core/services/gemini_service.dart';
import 'package:personal_branding_app/features/auth/data/repositories/auth_repository.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_branding_app/features/content_creation/data/repositories/content_creation_repository.dart';
import 'package:personal_branding_app/features/content_creation/domain/repositories/content_creation_repository.dart';
import 'package:personal_branding_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:personal_branding_app/features/onboarding/domain/repositories/onboarding_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Services
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<GeminiService>(),
    ),
  );

  getIt.registerLazySingleton<ContentCreationRepository>(
    () => ContentCreationRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<GeminiService>(),
    ),
  );
}
