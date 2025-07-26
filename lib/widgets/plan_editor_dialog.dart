import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_branding_app/models/content_plan_item.dart';
import 'package:personal_branding_app/providers/brand_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PlanEditorDialog extends StatefulWidget {
  final ContentPlanItem? planItem;

  const PlanEditorDialog({super.key, this.planItem});

  @override
  State<PlanEditorDialog> createState() => _PlanEditorDialogState();
}

class _PlanEditorDialogState extends State<PlanEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _topicController;
  late TextEditingController _captionController;
  late TextEditingController _visualController;

  DateTime _selectedDate = DateTime.now();
  String? _selectedPillar;
  String _selectedStatus = 'To Do';
  final _statusOptions = ['To Do', 'In Progress', 'Done', 'Published'];

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.planItem?.topic ?? '');
    _captionController = TextEditingController(text: widget.planItem?.caption ?? '');
    _visualController = TextEditingController(text: widget.planItem?.visualInfo ?? '');
    if (widget.planItem != null) {
      _selectedDate = widget.planItem!.date;
      _selectedPillar = widget.planItem!.pillar;
      _selectedStatus = widget.planItem!.status;
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      if (widget.planItem == null) {
        // Tambah baru
        final newItem = ContentPlanItem(
          id: const Uuid().v4(),
          date: _selectedDate,
          pillar: _selectedPillar!,
          topic: _topicController.text,
          caption: _captionController.text,
          visualInfo: _visualController.text,
          status: _selectedStatus,
        );
        brandProvider.addContentPlan(newItem);
      } else {
        // Update yang sudah ada
        final updatedItem = ContentPlanItem(
          id: widget.planItem!.id,
          date: _selectedDate,
          pillar: _selectedPillar!,
          topic: _topicController.text,
          caption: _captionController.text,
          visualInfo: _visualController.text,
          status: _selectedStatus,
        );
        brandProvider.updateContentPlan(updatedItem);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final pillars = brandProvider.contentPillars;
    if (_selectedPillar == null && pillars.isNotEmpty) {
      _selectedPillar = pillars.first;
    }


    return AlertDialog(
      title: Text(widget.planItem == null ? 'Tambah Rencana Baru' : 'Edit Rencana'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topik / Judul Konten'),
                validator: (value) => value!.isEmpty ? 'Topik tidak boleh kosong' : null,
              ),
              if (pillars.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedPillar,
                  items: pillars
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPillar = value),
                  decoration: const InputDecoration(labelText: 'Pilar Konten'),
                ),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _visualController,
                decoration: const InputDecoration(labelText: 'Info Visual'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(DateFormat.yMMMd().format(_selectedDate))),
                  TextButton(onPressed: _pickDate, child: const Text('Pilih Tanggal')),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitData,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}