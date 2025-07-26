import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_branding_app/models/content_plan_item.dart';
import 'package:personal_branding_app/providers/brand_provider.dart';
import 'package:personal_branding_app/widgets/plan_editor_dialog.dart';
import 'package:provider/provider.dart';

class ContentPlanScreen extends StatelessWidget {
  const ContentPlanScreen({super.key});

  void _showPlanEditor(BuildContext context, {ContentPlanItem? item}) {
    showDialog(
      context: context,
      builder: (ctx) => PlanEditorDialog(planItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BrandProvider>(
        builder: (context, provider, child) {
          if (provider.contentPlans.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada rencana konten.\nKlik tombol + untuk menambahkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          // Mengurutkan berdasarkan tanggal
          provider.contentPlans.sort((a, b) => a.date.compareTo(b.date));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.contentPlans.length,
            itemBuilder: (ctx, index) {
              final plan = provider.contentPlans[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      DateFormat('dd').format(plan.date),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  title: Text(plan.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${plan.pillar} - ${DateFormat('MMM yyyy').format(plan.date)}"),
                  trailing: Chip(
                    label: Text(plan.status),
                    backgroundColor: plan.status == 'Done' ? Colors.green.shade100 : Colors.orange.shade100,
                  ),
                  onTap: () => _showPlanEditor(context, item: plan),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanEditor(context),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}