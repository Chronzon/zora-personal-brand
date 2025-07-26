// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_branding_app/screens/content_ideas_screen.dart';
import 'package:personal_branding_app/screens/content_pillar_screen.dart';
import 'package:personal_branding_app/screens/content_plan_screen.dart'; // <-- IMPORT BARU
import 'package:personal_branding_app/screens/identity_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // -- TAMBAHKAN LAYAR BARU KE DALAM DAFTAR --
  static const List<Widget> _widgetOptions = <Widget>[
    IdentityBuilderScreen(),
    ContentPillarScreen(),
    ContentIdeasScreen(),
    ContentPlanScreen(), // <-- LAYAR KEEMPAT
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Judul AppBar akan berubah sesuai tab yang dipilih
    final List<String> titles = [
      'Personal Branding Builder',
      'Pilar Konten',
      'Ide Konten',
      'Perencanaan Konten'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Jati Diri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_column),
            label: 'Pilar Konten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Ide Konten',
          ),
          // -- TAMBAHKAN ITEM NAVIGASI BARU --
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Rencana', // <-- ITEM KEEMPAT
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
