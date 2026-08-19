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
                    subtitle: Text(
                      profile.id == controller.activeProfile?.id
                          ? 'Active local profile'
                          : 'Local profile',
                    ),
                    trailing: profile.id == controller.activeProfile?.id
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: profile.id == controller.activeProfile?.id
                        ? null
                        : () {
                            unawaited(controller.selectProfile(profile.id));
                          },
                  ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () {
                        unawaited(_showCreateProfileDialog(context));
                      },
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add profile'),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.activeProfile == null
                          ? null
                          : () {
                              unawaited(_showRenameProfileDialog(context));
                            },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Rename active'),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.profiles.length <= 1 ||
                              controller.activeProfile == null
                          ? null
                          : () {
                              unawaited(_confirmDeleteActiveProfile(context));
                            },
                      icon: const Icon(Icons.person_remove_outlined),
                      label: const Text('Delete active'),
                    ),
                  ],
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
                  subtitle: const Text('Reduce non-essential interface animation.'),
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
                  subtitle: const Text('Keep additional semantic guidance enabled.'),
                  value: settings.screenReaderHints,
                  onChanged: (bool value) {
                    unawaited(
                      controller.updateSettings(
                        settings.copyWith(screenReaderHints: value),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Confirm before leaving a quiz'),
                  subtitle: const Text('Protect an in-progress attempt from accidental exit.'),
                  value: settings.confirmBeforeExitQuiz,
                  onChanged: (bool value) {
                    unawaited(
                      controller.updateSettings(
                        settings.copyWith(confirmBeforeExitQuiz: value),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Privacy and data',
            icon: Icons.shield_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'QuizForge is offline-first. Profiles, questions, bookmarks, and quiz history stay in local application storage unless you explicitly export question-bank data.',
                ),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Read privacy details',
                  value: 'PRIVACY.md',
                  uri: Uri.parse(AppConstants.privacyUrl),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_toggle_off),
                  title: const Text('Clear active profile activity'),
                  subtitle: const Text(
                    'Deletes quiz history and bookmarks for the active profile. Questions and other profiles remain.',
                  ),
                  onTap: () {
                    unawaited(_confirmClearActivity(context));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Reset all local data',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  subtitle: const Text(
                    'Deletes local profiles, attempts, bookmarks, custom/imported questions, and settings, then restores starter data.',
                  ),
                  onTap: () {
                    unawaited(_confirmResetAll(context));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Updates',
            icon: Icons.system_update_alt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Installed version: ${AppConstants.version}'),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'QuizForge does not silently update itself. Review signed/tagged project releases and install through the distribution channel you trust.',
                ),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.new_releases_outlined,
                  label: 'View GitHub releases',
                  value: AppConstants.releasesUrl,
                  uri: Uri.parse(AppConstants.releasesUrl),
                ),
              ],
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
                  icon: Icons.security_outlined,
                  label: 'Security policy',
                  value: 'SECURITY.md',
                  uri: Uri.parse(AppConstants.securityUrl),
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
    final String? name = await _askForProfileName(
      context,
      title: 'Add local profile',
      actionLabel: 'Add',
    );
    if (name == null || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.createProfile(name),
      successMessage: 'Local profile created.',
    );
  }

  Future<void> _showRenameProfileDialog(BuildContext context) async {
    final PlayerProfile? current = controller.activeProfile;
    if (current == null) {
      return;
    }
    final String? name = await _askForProfileName(
      context,
      title: 'Rename active profile',
      actionLabel: 'Rename',
      initialValue: current.displayName,
    );
    if (name == null || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.renameActiveProfile(name),
      successMessage: 'Profile renamed.',
    );
  }

  Future<String?> _askForProfileName(
    BuildContext context, {
    required String title,
    required String actionLabel,
    String initialValue = '',
  }) async {
    final TextEditingController nameController =
        TextEditingController(text: initialValue);
    try {
      return await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: nameController,
              autofocus: true,
              maxLength: 32,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Display name'),
              onSubmitted: (String value) {
                if (value.trim().length >= 2) {
                  Navigator.of(dialogContext).pop(value.trim());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(nameController.text.trim()),
                child: Text(actionLabel),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _confirmDeleteActiveProfile(BuildContext context) async {
    final PlayerProfile? profile = controller.activeProfile;
    if (profile == null || controller.profiles.length <= 1) {
      return;
    }
    final bool confirmed = await _confirm(
      context,
      title: 'Delete active profile?',
      message:
          'This permanently removes this profile, its quiz history, and its bookmarks from this device. Questions remain.',
      confirmLabel: 'Delete profile',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.deleteProfile(profile.id),
      successMessage: 'Profile deleted.',
    );
  }

  Future<void> _confirmClearActivity(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      title: 'Clear active profile activity?',
      message:
          'Quiz history, statistics, and bookmarks for the active profile will be permanently deleted. Questions and profiles remain.',
      confirmLabel: 'Clear activity',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: controller.clearActiveProfileActivity,
      successMessage: 'Active profile activity cleared.',
    );
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      title: 'Reset all local QuizForge data?',
      message:
          'This permanently deletes profiles, history, bookmarks, custom/imported questions, and settings from this app. Starter questions and a default local profile will be recreated.',
      confirmLabel: 'Reset everything',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: controller.resetAllLocalData,
      successMessage: 'QuizForge local data was reset.',
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _runAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
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
