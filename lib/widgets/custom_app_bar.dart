import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.0,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        if (showMenuButton)
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Fungsi hamburger menu nanti
            },
          )
        else
          const SizedBox(width: 48), // Beri ruang kosong agar judul tetap di tengah
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
