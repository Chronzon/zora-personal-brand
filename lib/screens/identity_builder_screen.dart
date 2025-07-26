// lib/screens/identity_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/providers/brand_provider.dart';
import 'package:personal_branding_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class IdentityBuilderScreen extends StatelessWidget {
  const IdentityBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil instance provider agar bisa menyimpan data
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Text(
          '1. Temukan Jati Diri Personal Brand-mu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Jawab pertanyaan ini untuk membangun fondasi merek pribadimu. Jawabanmu akan digunakan oleh AI untuk memberikan saran.',
           style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // Menggunakan CustomTextField dengan parameter yang benar
        CustomTextField(
          label: 'Siapa kamu? (Peran, Latar Belakang)',
          initialValue: brandProvider.brand.whoAreYou,
          onChanged: (value) => brandProvider.updateWhoAreYou(value),
        ),
        CustomTextField(
          label: 'Apa Keahlian Utamamu?',
          initialValue: brandProvider.brand.mainSkill,
          onChanged: (value) => brandProvider.updateMainSkill(value),
        ),
        CustomTextField(
          label: 'Apa Passion/Minat Terbesarmu?',
          initialValue: brandProvider.brand.passion,
          onChanged: (value) => brandProvider.updatePassion(value),
        ),
        CustomTextField(
          label: 'Apa Nilai-nilai yang Kamu Pegang Teguh?',
          initialValue: brandProvider.brand.values,
          onChanged: (value) => brandProvider.updateValues(value),
        ),
        CustomTextField(
          label: 'Topik Niche Apa yang Ingin Kamu Kuasai?',
          initialValue: brandProvider.brand.nicheTopic,
          onChanged: (value) => brandProvider.updateNicheTopic(value),
        ),
        CustomTextField(
          label: 'Siapa Target Audiensmu?',
          initialValue: brandProvider.brand.targetAudience,
          onChanged: (value) => brandProvider.updateTargetAudience(value),
        ),
        CustomTextField(
          label: 'Masalah Apa yang Ingin Kamu Selesaikan untuk Mereka?',
          initialValue: brandProvider.brand.problemToSolve,
          onChanged: (value) => brandProvider.updateProblemToSolve(value),
        ),
         CustomTextField(
          label: 'Apa Pernyataan Merek (Brand Statement) Kamu?',
          initialValue: brandProvider.brand.brandStatement,
          onChanged: (value) => brandProvider.updateBrandStatement(value),
          maxLines: 4,
        ),
      ],
    );
  }
}
