import 'package:flutter/material.dart';
import '../../../onboarding/presentation/pages/name_screen.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class StrategyTab extends StatelessWidget {
  const StrategyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Brand Strategy',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: onboardingProvider.isOnboardingComplete
          ? LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 700;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Bagian Atas: Audience & Monetization ---
                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildSectionGroup(
                                    'Target Audience',
                                    onboardingProvider
                                        .brandProfile.targetAudience,
                                    Icons.groups_outlined)),
                            const SizedBox(width: 24),
                            Expanded(
                                child: _buildSectionGroup(
                                    'Monetization',
                                    onboardingProvider
                                        .brandProfile.opportunities,
                                    Icons.attach_money)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildSectionGroup(
                                'Target Audience',
                                onboardingProvider.brandProfile.targetAudience,
                                Icons.groups_outlined),
                            const SizedBox(height: 24),
                            _buildSectionGroup(
                                'Monetization',
                                onboardingProvider.brandProfile.opportunities,
                                Icons.attach_money),
                          ],
                        ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // --- Bagian Bawah: SWOT Analysis ---
                      const Text(
                        'SWOT ANALYSIS',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),

                      // Grid SWOT yang responsif
                      _buildSwotGrid(onboardingProvider, isTablet),
                    ],
                  ),
                );
              },
            )
          : _buildIncompleteState(context),
    );
  }

  Widget _buildIncompleteState(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: purpleColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your brand strategy is not complete yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your setup to unlock your audience, monetization, SWOT, and content pillar strategy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const NameScreen(showBackButton: false),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Continue Setup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionGroup(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF8A53FF), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  content.isNotEmpty ? content : 'Not set yet',
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFF424242)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwotGrid(OnboardingProvider provider, bool isTablet) {
    // Data struktur untuk SWOT - sekarang dari brandProfile
    final swotData = [
      {
        'label': 'Strengths',
        'val': provider.brandProfile.strengths,
        'bg': Colors.green.shade50,
        'acc': Colors.green
      },
      {
        'label': 'Weaknesses',
        'val': provider.brandProfile.weaknesses,
        'bg': Colors.orange.shade50,
        'acc': Colors.orange
      },
      {
        'label': 'Opportunities',
        'val': 'Lihat bagian monetisasi',
        'bg': Colors.blue.shade50,
        'acc': Colors.blue
      },
      {
        'label': 'Threats',
        'val': provider.brandProfile.threats,
        'bg': Colors.red.shade50,
        'acc': Colors.red
      },
    ];

    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final item = swotData[index];
          return _buildSwotItem(item['label'] as String, item['val'] as String,
              item['bg'] as Color, item['acc'] as Color);
        },
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildSwotItem(
                      'Strengths',
                      provider.brandProfile.strengths,
                      Colors.green.shade50,
                      Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSwotItem(
                      'Weaknesses',
                      provider.brandProfile.weaknesses,
                      Colors.orange.shade50,
                      Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildSwotItem(
                      'Threats',
                      provider.brandProfile.threats,
                      Colors.red.shade50,
                      Colors.red)),
              const SizedBox(width: 12),
              Expanded(
                  child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent))),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSwotItem(
      String label, String value, Color bgColor, Color accentColor) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
