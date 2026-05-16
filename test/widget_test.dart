import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:personal_branding_app/features/auth/presentation/pages/login_screen.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:provider/provider.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user});

  ApiUser? user;

  @override
  ApiUser? get currentUser => user;

  @override
  Future<bool> restoreSession() async => user != null;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    user = const ApiUser(
      id: '1',
      email: 'user@example.com',
      name: 'User',
    );
    return AuthResult(user!);
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    user = ApiUser(
      id: '1',
      email: email,
      name: fullName,
    );
    return AuthResult(user!);
  }

  @override
  Future<void> signOut() async {
    user = null;
  }

  @override
  Future<bool> signInWithGoogle() async => false;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('welcome start sends unauthenticated users to login',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(FakeAuthRepository()),
        child: const MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Mulai Branding Sekarang'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back! 👋'), findsOneWidget);
  });
}
