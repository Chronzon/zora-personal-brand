import 'package:flutter/material.dart';
import 'package:personal_branding_app/features/onboarding/presentation/pages/name_screen.dart';
import 'package:personal_branding_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class StrategyTab extends StatelessWidget {
  const StrategyTab({super.key});

  static const Color _purpleColor = Color(0xFF8A53FF);
  static const Color _backgroundColor = Color(0xFFF8F9FE);
  static const Color _inkColor = Color(0xFF171717);

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.strategyTitle,
          style: const TextStyle(
            color: _inkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _DashboardBackground(
        child: onboardingProvider.isOnboardingComplete
            ? _buildStrategyBody(context, onboardingProvider, l10n)
            : _buildIncompleteState(context, l10n),
      ),
    );
  }

  Widget _buildStrategyBody(
    BuildContext context,
    OnboardingProvider provider,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final horizontalPadding = isWide ? 32.0 : 16.0;

        return SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 18),
                  _buildProfileSummary(provider, l10n),
                  const SizedBox(height: 16),
                  _buildResponsiveCards(
                    isWide: isWide,
                    children: [
                      _buildTextSection(
                        title: l10n.targetAudienceLabel,
                        icon: Icons.groups_2_outlined,
                        accentColor: Colors.blue.shade700,
                        value: _displayValue(
                          provider.brandProfile.targetAudience,
                          l10n,
                        ),
                      ),
                      _buildMonetizationSection(provider, l10n),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildIkigaiSection(provider, l10n),
                  const SizedBox(height: 16),
                  _buildSwotSection(provider, l10n, isWide),
                  const SizedBox(height: 16),
                  _buildContentPillarsSection(provider, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.strategyTitle,
          style: const TextStyle(
            fontSize: 26,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: _inkColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.strategySubtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _Panel(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _purpleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: _purpleColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.strategyIncompleteTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _inkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.strategyIncompleteBody,
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
                    label: Text(l10n.continueSetup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purpleColor,
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

  Widget _buildProfileSummary(
    OnboardingProvider provider,
    AppLocalizations l10n,
  ) {
    final brand = provider.brandProfile;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.badge_outlined,
            title: l10n.profileSummaryTitle,
            accentColor: _purpleColor,
          ),
          const SizedBox(height: 16),
          _buildKeyValue(
              l10n.profileNameLabel, brand.selectedProfileName, l10n),
          _buildKeyValue(l10n.categoryLabel, brand.selectedCategory, l10n),
          _buildKeyValue(l10n.microNicheLabel, brand.selectedMicroNiche, l10n),
          _buildKeyValue(l10n.premiseLabel, brand.selectedPremise, l10n),
          _buildKeyValue(l10n.toneOfVoiceLabel, brand.toneOfVoice, l10n),
        ],
      ),
    );
  }

  Widget _buildIkigaiSection(
    OnboardingProvider provider,
    AppLocalizations l10n,
  ) {
    final user = provider.userProfile;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.psychology_alt_outlined,
            title: l10n.ikigaiAnswersTitle,
            accentColor: Colors.indigo.shade600,
          ),
          const SizedBox(height: 16),
          _buildKeyValue(l10n.whatILoveLabel, user.whatILove, l10n),
          _buildKeyValue(l10n.whatImGoodAtLabel, user.whatImGoodAt, l10n),
          _buildKeyValue(
              l10n.whatTheWorldNeedsLabel, user.whatTheWorldNeeds, l10n),
          _buildKeyValue(
              l10n.whatICanBePaidForLabel, user.whatICanBePaidFor, l10n),
        ],
      ),
    );
  }

  Widget _buildSwotSection(
    OnboardingProvider provider,
    AppLocalizations l10n,
    bool isWide,
  ) {
    final brand = provider.brandProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            l10n.swotAnalysisTitle.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        _buildResponsiveCards(
          isWide: isWide,
          children: [
            _buildTextSection(
              title: l10n.strengthsLabel,
              icon: Icons.trending_up_rounded,
              accentColor: Colors.green.shade700,
              value: _displayValue(brand.strengths, l10n),
            ),
            _buildTextSection(
              title: l10n.weaknessesLabel,
              icon: Icons.warning_amber_rounded,
              accentColor: Colors.orange.shade700,
              value: _displayValue(brand.weaknesses, l10n),
            ),
            _buildTextSection(
              title: l10n.opportunitiesLabel,
              icon: Icons.lightbulb_outline_rounded,
              accentColor: Colors.blue.shade700,
              value: _displayValue(brand.opportunities, l10n),
            ),
            _buildTextSection(
              title: l10n.threatsLabel,
              icon: Icons.shield_outlined,
              accentColor: Colors.red.shade700,
              value: _displayValue(brand.threats, l10n),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentPillarsSection(
    OnboardingProvider provider,
    AppLocalizations l10n,
  ) {
    final pillars = provider.brandProfile.contentPillars;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.view_column_outlined,
            title: l10n.contentPillarsTitle,
            accentColor: Colors.deepPurple.shade600,
          ),
          const SizedBox(height: 14),
          if (pillars.isEmpty)
            Text(
              l10n.contentPillarsEmpty,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade600,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < pillars.length; index++) ...[
                  _PillarRow(index: index + 1, text: pillars[index]),
                  if (index != pillars.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCards({
    required bool isWide,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final child in children)
              SizedBox(
                width: width,
                child: child,
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String value,
    String? subtitle,
  }) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: icon,
            title: title,
            subtitle: subtitle,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetizationSection(
    OnboardingProvider provider,
    AppLocalizations l10n,
  ) {
    final options = provider.brandProfile.monetizationOptions;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.payments_outlined,
            title: l10n.monetizationTitle,
            subtitle: l10n.whatICanBePaidForLabel,
            accentColor: Colors.teal.shade700,
          ),
          const SizedBox(height: 14),
          _LabelledText(
            label: l10n.monetizationYourAnswerLabel,
            value: _displayValue(provider.userProfile.whatICanBePaidFor, l10n),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          Text(
            l10n.monetizationAiSuggestionsLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              l10n.notSetYet,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF333333),
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < options.length; index++) ...[
                  _SuggestionRow(text: options[index]),
                  if (index != options.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildKeyValue(
    String label,
    String? value,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _displayValue(value, l10n),
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _inkColor,
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? l10n.notSetYet : value!;
  }
}

class _LabelledText extends StatelessWidget {
  const _LabelledText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: Colors.teal.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: StrategyTab._inkColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1EAFF),
            StrategyTab._backgroundColor,
            Colors.white,
          ],
          stops: [0, 0.42, 1],
        ),
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.accentColor,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: StrategyTab._inkColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StrategyTab._purpleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: StrategyTab._purpleColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: StrategyTab._inkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
