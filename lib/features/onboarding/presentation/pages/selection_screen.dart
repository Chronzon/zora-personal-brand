// lib/onboarding/selection_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/widgets/custom_app_bar.dart';

class SelectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelect;
  final VoidCallback onNext;

  const SelectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
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
    const purpleColor = Color(0xFF8A53FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'BrandBuilder AI',
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final padding = isMobile ? 24.0 : 48.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed:
                                _selectedValue != null ? widget.onNext : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          )
                        ],
                      ),
                    const SizedBox(height: 48),
                    // Responsive Options Layout
                    if (isMobile) ...[
                      Column(
                        children: widget.options.map((option) {
                          final isSelected = _selectedValue == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedValue = isSelected ? null : option;
                                });
                                if (_selectedValue != null) {
                                  widget.onSelect(_selectedValue!);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? purpleColor.withOpacity(0.05)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? purpleColor
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.bold, // Match web bold
                                    color: isSelected
                                        ? purpleColor
                                        : Colors.black, // Match web black
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _selectedValue != null ? widget.onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      )
                    ] else
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: widget.options.map((option) {
                          final isSelected = _selectedValue == option;
                          return HoverAnimatedChip(
                            label: option,
                            isSelected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedValue = selected ? option : null;
                              });
                              if (_selectedValue != null) {
                                widget.onSelect(_selectedValue!);
                              }
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// --- WIDGET BARU UNTUK CHIP DENGAN ANIMASI HOVER ---
class HoverAnimatedChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const HoverAnimatedChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<HoverAnimatedChip> createState() => _HoverAnimatedChipState();
}

class _HoverAnimatedChipState extends State<HoverAnimatedChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0, // Membesar 5% saat di-hover
        duration: const Duration(milliseconds: 200),
        child: Theme(
          data: Theme.of(context).copyWith(
            // Menghilangkan efek warna abu-abu saat di-hover atau ditekan
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ChoiceChip(
            label: Text(widget.label),
            selected: widget.isSelected,
            onSelected: widget.onSelected,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            labelStyle: TextStyle(
              color: widget.isSelected ? purpleColor : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            selectedColor: Colors.grey.shade100,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: widget.isSelected ? purpleColor : Colors.grey.shade300,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            showCheckmark: false,
            pressElevation: 0,
          ),
        ),
      ),
    );
  }
}
