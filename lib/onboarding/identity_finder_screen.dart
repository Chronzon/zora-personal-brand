import 'package:flutter/material.dart';
import 'package:personal_branding_app/onboarding/ai_result_screen.dart';
import 'package:personal_branding_app/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class IdentityFinderScreen extends StatefulWidget {
  const IdentityFinderScreen({super.key});

  @override
  State<IdentityFinderScreen> createState() => _IdentityFinderScreenState();
}

class _IdentityFinderScreenState extends State<IdentityFinderScreen> {
  final _formKey = GlobalKey<FormState>();

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await Provider.of<OnboardingProvider>(context, listen: false).generateIdentity();
      
      // Cek apakah ada hasil atau error setelah generate
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      if (provider.aiResponse != null) {
         Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AiResultScreen(),
        ));
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('FINDER PERSONAL IDENTITY')),
      body: Consumer<OnboardingProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTextField(
                  label: 'YANG KAMU SUKAI',
                  hint: '(bikin semangat & ngga ngebosenin)',
                  onSaved: (val) => provider.whatILove = val!,
                ),
                _buildTextField(
                  label: 'YANG KAMU BISA',
                  hint: '(skill / kemampuan yang dikuasai)',
                  onSaved: (val) => provider.whatImGoodAt = val!,
                ),
                _buildTextField(
                  label: 'KENAPA DIBUTUHKAN?',
                  hint: '(kepentingan & manfaat untuk orang lain)',
                  onSaved: (val) => provider.whatTheWorldNeeds = val!,
                ),
                _buildTextField(
                  label: 'PELUANG PENGHASILAN (Opsional)',
                  hint: '(ngga perlu di isi kalau bingung)',
                  onSaved: (val) => provider.whatICanBePaidFor = val!,
                  isOptional: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generate,
                  child: const Text('Generate'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: 3,
        onSaved: onSaved,
        validator: (value) {
          if (!isOptional && value!.isEmpty) {
            return 'Field ini tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}