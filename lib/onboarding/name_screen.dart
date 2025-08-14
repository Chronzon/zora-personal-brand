import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/identity_finder_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      Provider.of<OnboardingProvider>(context, listen: false)
          .updateFullName(_controller.text);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const IdentityFinderScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna ungu yang akan kita gunakan
    const purpleColor = Color(0xFF6026F0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Menambah tinggi AppBar
        child: AppBar(
          toolbarHeight: 80.0, // <-- TAMBAHKAN INI
          backgroundColor: Colors.white,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          title: const Text(
            'BrandBuilder AI',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Log In',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
            // Membungkus tombol kedua dengan Center juga
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 900), // Sedikit lebih lebar
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Launch Data-Driven Campaigns in Minutes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          36, // Ukuran font disesuaikan agar muat satu baris
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Our free AI tool generates complete digital strategies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.w500, // Sedikit tebal agar pekat
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Mobile Business/Organization/Your Name',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF5F5F5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: purpleColor,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Name can not be empty' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 75, // Menyamakan tinggi dengan TextFormField
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Get started',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Jarak ke ulasan Trustpilot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Excellent',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(
                            5,
                            (index) => const Icon(Icons.star,
                                color: Color(0xFF00B67A), size: 20)),
                      ),
                      const SizedBox(width: 8),
                      const Text('7,000+ reviews on'),
                      const SizedBox(width: 8),
                      const Icon(Icons.star,
                          color: Color(0xFF00B67A), size: 20),
                      const Text('Trustpilot',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
