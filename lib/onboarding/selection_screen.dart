import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  final String title;
  final List<String> options;
  final Function(String) onSelect;
  final VoidCallback onNext;

  const SelectionScreen({
    super.key,
    required this.title,
    required this.options,
    required this.onSelect,
    required this.onNext,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: widget.options.length,
        itemBuilder: (context, index) {
          final option = widget.options[index];
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              if (value != null) {
                widget.onSelect(value);
              }
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: const Text('Next'),
          onPressed: _selectedValue != null ? widget.onNext : null,
        ),
      ),
    );
  }
}