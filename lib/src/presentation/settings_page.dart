import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/quizforge_controller.dart';
import '../core/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../domain/app_settings.dart';
import '../domain/profile.dart';

final class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = controller.settings;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: 'Profiles',
            icon: Icons.people_outline,
            child: Column(
              children: <Widget>[
                for (final PlayerProfile profile in controller.profiles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(profile.displayName),
                    subtitle: Text(profile.id),
                    trailing: profile.id == controller.activeProfile?.id
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: profile.id == controller.activeProfile?.id
                        ? null
                        : () {
                            unawaited(controller.selectProfile(profile.id));
                          },
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      unawaited(_showCreateProfileDialog(context));
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add local profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Theme'),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AppThemeMode>(
                  segments: const <ButtonSegment<AppThemeMode>>[
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: <AppThemeMode>{settings.themeMode},
                  onSelectionChanged: (Set<AppThemeMode> selected) {
                    unawaited(
                      controller.updateSettings(
                        settings.copyWith(themeMode: selected.single),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Accessibility',
            icon: Icons.accessibility_new,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Large text'),
                  subtitle: const Text('Increase QuizForge text size across the app.'),
                  value: settings.largeText,
                  onChanged: (bool value) {
                    unawaited(
                      controller.updateSettings(settings.copyWith(largeText: value)),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduced motion'),
                  subtitle: const Text('Prefer minimal interface motion and transitions.'),
                  value: settings.reducedMotion,
                  onChanged: (bool value) {
                    unawaited(
                      controller.updateSettings(
                        settings.copyWith(reducedMotion: value),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Screen-reader hints'),
                  subtitle: const Text('Keep extra semantic hints enabled where helpful.'),
                  value: settings.screenReaderHints,
                  onChanged: (bool value) {
                    unawaited(
                      controller.updateSettings(
                        settings.copyWith(screenReaderHints: value),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Section(
            title: 'Privacy and data',
            icon: Icons.shield_outlined,
            child: Text(
              'QuizForge is offline-first. Profiles, questions, bookmarks, and quiz history are stored locally unless you explicitly copy/export a question bank. The core app does not require sign-in.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'About',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${AppConstants.appName} ${AppConstants.version}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Open-source quiz game and authoring toolkit. Licensed under MIT.'),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.code,
                  label: 'GitHub repository',
                  value: AppConstants.githubUrl,
                  uri: Uri.parse(AppConstants.githubUrl),
                ),
                _LinkTile(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Buy Me a Coffee',
                  value: AppConstants.buyMeACoffeeUrl,
                  uri: Uri.parse(AppConstants.buyMeACoffeeUrl),
                ),
                _LinkTile(
                  icon: Icons.business_center_outlined,
                  label: 'Business email',
                  value: AppConstants.businessEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.businessEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge'},
                  ),
                ),
                _LinkTile(
                  icon: Icons.email_outlined,
                  label: 'Business email 2',
                  value: AppConstants.secondaryBusinessEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.secondaryBusinessEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge'},
                  ),
                ),
                _LinkTile(
                  icon: Icons.support_agent_outlined,
                  label: 'Support email',
                  value: AppConstants.supportEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.supportEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge support'},
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppConstants.credit,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateProfileDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    try {
      final String? name = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add local profile'),
            content: TextField(
              controller: nameController,
              autofocus: true,
              maxLength: 32,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Display name'),
              onSubmitted: (String value) {
                if (value.trim().length >= 2) {
                  Navigator.of(context).pop(value.trim());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(nameController.text.trim()),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
      if (name == null || name.isEmpty || !context.mounted) {
        return;
      }
      try {
        await controller.createProfile(name);
      } on Object catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$error')),
          );
        }
      }
    } finally {
      nameController.dispose();
    }
  }
}

final class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

final class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.uri,
  });

  final IconData icon;
  final String label;
  final String value;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        unawaited(_launch(context));
      },
    );
  }

  Future<void> _launch(BuildContext context) async {
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $value')),
      );
    }
  }
}
