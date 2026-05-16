import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_branding_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_branding_app/features/content_creation/presentation/providers/content_creation_provider.dart';
import 'package:personal_branding_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final bool showBackButton;
  const LoginScreen({super.key, this.showBackButton = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State untuk Toggle Mode (Login vs Register)
  bool _isLoginMode = true;
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeAuthNavigation() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    final contentProvider = context.read<ContentCreationProvider>();

    await onboardingProvider.loadUserData();

    if (mounted) {
      await contentProvider.loadScripts();
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      bool success = false;

      if (_isLoginMode) {
        success = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }

      if (success && mounted) {
        await _completeAuthNavigation();
      } else if (mounted) {
        // Tampilkan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Terjadi kesalahan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        // <--- 1. Bungkus dengan Stack
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;

              if (isDesktop) {
                // --- DESKTOP LAYOUT (SPLIT SCREEN) ---
                return Row(
                  children: [
                    // Sisi Kiri: Branding / Image
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: purpleColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 100, color: Colors.white),
                              const SizedBox(height: 24),
                              Text(
                                "BrandBuilder AI",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Bangun Personal Branding Anda\ndengan Kekuatan AI",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sisi Kanan: Form
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: _buildFormContent(purpleColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // --- MOBILE LAYOUT (CLEAN MINIMALIST) ---
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _buildFormContent(purpleColor),
                    ),
                  ),
                );
              }
            },
          ),
          if (widget.showBackButton)
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormContent(Color primaryColor) {
    final provider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Header Animasi
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_isLoginMode),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoginMode ? "Welcome Back! 👋" : "Create Account 🚀",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode
                      ? "Masuk untuk melanjutkan strategi branding Anda."
                      : "Daftar gratis dan mulai bangun personal branding.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 2. Field Nama (Hanya muncul saat Register)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _isLoginMode
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),

          // 3. Field Email
          _buildTextField(
            controller: _emailController,
            label: "Email Address",
            icon: Icons.email_outlined,
            primaryColor: primaryColor,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // 4. Field Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return "Password minimal 6 karakter";
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Lupa Password (Hanya Login)
          if (_isLoginMode)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Todo: Implement Forgot Password
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Fitur Reset Password akan segera hadir")));
                },
                child: Text("Forgot Password?",
                    style: TextStyle(color: primaryColor)),
              ),
            ),

          const SizedBox(height: 24),

          // 5. Tombol Utama
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isLoginMode ? "Login" : "Sign Up",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // 6. Divider Social Login
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Or continue with",
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          // 7. Social Button (Google)
          OutlinedButton.icon(
            onPressed: () async {
              final provider = context.read<AuthProvider>();

              // Panggil fungsi Google Sign In
              final success = await provider.signInWithGoogle();

              if (!mounted) return;

              if (success) {
                await _completeAuthNavigation();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          provider.errorMessage ?? "Google Sign In Gagal")),
                );
              }
            },
            icon: SvgPicture.asset(
              'assets/images/google_logo.svg',
              height: 24,
              width: 24,
            ),
            // --- PERUBAHAN LABEL DI SINI ---
            label: Text(
              _isLoginMode ? "Log in with Google" : "Sign up with Google",
              style: GoogleFonts.plusJakartaSans(
                fontWeight:
                    FontWeight.bold, // Samakan ketebalan dengan tombol lain
                color: Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      16)), // Samakan radius dengan tombol utama (16)
            ),
          ),

          const SizedBox(height: 32),

          // 8. Toggle Mode Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLoginMode
                    ? "Don't have an account? "
                    : "Already have an account? ",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode ? "Sign Up" : "Login",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label tidak boleh kosong";
        }
        return null;
      },
    );
  }
}
