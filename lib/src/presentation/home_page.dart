import 'package:flutter/material.dart';

import '../application/quizforge_controller.dart';
import '../core/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'creator_page.dart';
import 'dashboard_page.dart';
import 'question_bank_page.dart';
import 'settings_page.dart';
import 'stats_page.dart';

final class HomePage extends StatefulWidget {
  const HomePage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

final class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardPage(controller: widget.controller),
      QuestionBankPage(controller: widget.controller),
      CreatorPage(controller: widget.controller),
      StatsPage(controller: widget.controller),
      SettingsPage(controller: widget.controller),
    ];

    final bool wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
    final Widget body = IndexedStack(index: _selectedIndex, children: pages);

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: <Widget>[
            _ProfileChip(controller: widget.controller),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
        body: Row(
          children: <Widget>[
            SafeArea(
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                destinations: _railDestinations,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: <Widget>[
          _ProfileChip(controller: widget.controller),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        destinations: _barDestinations,
      ),
    );
  }

  void _select(int value) {
    if (value == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = value);
  }

  static const List<NavigationRailDestination> _railDestinations =
      <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.library_books_outlined),
      selectedIcon: Icon(Icons.library_books),
      label: Text('Bank'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.add_circle_outline),
      selectedIcon: Icon(Icons.add_circle),
      label: Text('Create'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: Text('Stats'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  static const List<NavigationDestination> _barDestinations =
      <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.library_books_outlined),
      selectedIcon: Icon(Icons.library_books),
      label: 'Bank',
    ),
    NavigationDestination(
      icon: Icon(Icons.add_circle_outline),
      selectedIcon: Icon(Icons.add_circle),
      label: 'Create',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Stats',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
}

final class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.controller});

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final String label = controller.activeProfile?.displayName ?? 'No profile';
    return Semantics(
      label: 'Active profile: $label',
      child: Chip(
        avatar: const Icon(Icons.person_outline, size: 18),
        label: Text(label),
      ),
    );
  }
}
