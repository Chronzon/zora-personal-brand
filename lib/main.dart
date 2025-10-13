import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personal_branding_app/onboarding/name_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the .env file
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan MultiProvider jika nanti ada provider lain
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // ChangeNotifierProvider(create: (_) => BrandProvider()), // Provider lama bisa dinonaktifkan dulu
      ],
      child: MaterialApp(
        title: 'Personal Branding Builder',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        // Mulai dari layar pertama onboarding
        home: const NameScreen(),
      ),
    );
  }
}