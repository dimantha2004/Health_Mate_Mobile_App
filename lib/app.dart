import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/view/dashboard_screen.dart';
import 'features/goals/view/goals_screen.dart';
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

/// Navigation between the main tabs with a shared "Add record" button.
///
/// Follows Material's adaptive navigation guidance: a bottom NavigationBar
/// on phones in portrait, and a side NavigationRail when the screen is at
/// least 600dp wide (landscape phones, tablets) so content keeps its height.
/// IndexedStack keeps each tab's scroll position when switching.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _goalsTab = 2;
  static const _tabs = [
    (
      title: 'HealthMate',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    (
      title: 'Health Records',
      label: 'Records',
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt_rounded,
    ),
    (
      title: 'Goals',
      label: 'Goals',
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag_rounded,
    ),
  ];

  void _addRecord() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecordFormScreen()),
      );

  void _select(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final showAdd = _tab != _goalsTab;

    // Content stays a readable width instead of stretching edge to edge.
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: IndexedStack(
          index: _tab,
          children: const [DashboardScreen(), RecordsScreen(), GoalsScreen()],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(_tabs[_tab].title)),
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _tab,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    leading: showAdd
                        ? FloatingActionButton(
                            onPressed: _addRecord,
                            tooltip: 'Add record',
                            elevation: 0,
                            child: const Icon(Icons.add_rounded),
                          )
                        : const SizedBox(height: 56),
                    destinations: [
                      for (final tab in _tabs)
                        NavigationRailDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: Text(tab.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
      floatingActionButton: !wide && showAdd
          ? FloatingActionButton.extended(
              onPressed: _addRecord,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add record'),
            )
          : null,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: _select,
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.label,
                  ),
              ],
            ),
    );
  }
}
