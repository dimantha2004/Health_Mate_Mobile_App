import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/view/dashboard_screen.dart';
import 'features/health_records/view/record_form_screen.dart';
import 'features/health_records/view/records_screen.dart';

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeShell(),
      );
}

/// Bottom navigation between the main tabs, with a shared "Add record"
/// button. IndexedStack keeps each tab's scroll position when switching.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _titles = ['HealthMate', 'Health Records'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: const [DashboardScreen(), RecordsScreen()],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecordFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add record'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
