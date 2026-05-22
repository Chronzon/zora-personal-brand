import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../widgets/home_tab.dart';
import '../widgets/strategy_tab.dart';
import '../widgets/content_tab.dart';
import 'package:personal_branding_app/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const StrategyTab(),
    const ContentTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8A53FF);
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.dashboardHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.map_outlined),
        selectedIcon: const Icon(Icons.map),
        label: l10n.dashboardStrategy,
      ),
      NavigationDestination(
        icon: const Icon(Icons.auto_awesome_outlined),
        selectedIcon: const Icon(Icons.auto_awesome),
        label: l10n.dashboardContent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cek apakah layar lebar (Tablet/Desktop)
        final isWideScreen = constraints.maxWidth > 640;

        if (isWideScreen) {
          // --- TAMPILAN TABLET (Navigation Rail di Kiri) ---
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: purpleColor),
                  selectedLabelTextStyle: const TextStyle(
                      color: purpleColor, fontWeight: FontWeight.bold),
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: Text(d.label),
                          ))
                      .toList(),
                  // Tambahan estetika: Garis pemisah vertikal
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Konten di sebelah kanan mengisi sisa ruang
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          );
        } else {
          // --- TAMPILAN MOBILE (Bottom Navigation Bar) ---
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: _pages[_selectedIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() => _selectedIndex = index);
                },
                backgroundColor: Colors.white,
                indicatorColor: purpleColor.withValues(alpha: 0.2),
                destinations: destinations,
              ),
            ),
          );
        }
      },
    );
  }
}
