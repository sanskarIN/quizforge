import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
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
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<Widget> pages = <Widget>[
      DashboardPage(controller: widget.controller),
      QuestionBankPage(controller: widget.controller),
      CreatorPage(controller: widget.controller),
      StatsPage(controller: widget.controller),
      SettingsPage(controller: widget.controller),
    ];
    final List<NavigationRailDestination> railDestinations =
        <NavigationRailDestination>[
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: Text(strings.home),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.library_books_outlined),
        selectedIcon: const Icon(Icons.library_books),
        label: Text(strings.bank),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.add_circle_outline),
        selectedIcon: const Icon(Icons.add_circle),
        label: Text(strings.create),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights),
        label: Text(strings.stats),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: Text(strings.settings),
      ),
    ];
    final List<NavigationDestination> barDestinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: strings.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.library_books_outlined),
        selectedIcon: const Icon(Icons.library_books),
        label: strings.bank,
      ),
      NavigationDestination(
        icon: const Icon(Icons.add_circle_outline),
        selectedIcon: const Icon(Icons.add_circle),
        label: strings.create,
      ),
      NavigationDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights),
        label: strings.stats,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: strings.settings,
      ),
    ];

    final bool wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
    final Widget body = IndexedStack(index: _selectedIndex, children: pages);

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          title: Text(strings.appName),
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
                destinations: railDestinations,
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
        title: Text(strings.appName),
        actions: <Widget>[
          _ProfileChip(controller: widget.controller),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        destinations: barDestinations,
      ),
    );
  }

  void _select(int value) {
    if (value == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = value);
  }
}

final class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.controller});

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String label = controller.activeProfile?.displayName ?? strings.noProfile;
    return Semantics(
      label: '${strings.activeProfile}: $label',
      child: Chip(
        avatar: const Icon(Icons.person_outline, size: 18),
        label: Text(label),
      ),
    );
  }
}
