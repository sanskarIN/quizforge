import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../domain/app_settings.dart';
import '../domain/profile.dart';
import 'about_page.dart';

final class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AppSettings settings = controller.settings;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(
            strings.settings,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: strings.profiles,
            icon: Icons.people_outline,
            child: Column(
              children: <Widget>[
                for (final PlayerProfile profile in controller.profiles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(profile.displayName),
                    subtitle: Text(
                      profile.id == controller.activeProfile?.id
                          ? strings.activeLocalProfile
                          : strings.localProfile,
                    ),
                    trailing: profile.id == controller.activeProfile?.id
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: profile.id == controller.activeProfile?.id
                        ? null
                        : () {
                            unawaited(
                              _runSilentAction(
                                context,
                                action: () => controller.selectProfile(profile.id),
                                failureEvent: 'profile.select.failed',
                              ),
                            );
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
                      label: Text(strings.addProfile),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.activeProfile == null
                          ? null
                          : () {
                              unawaited(_showRenameProfileDialog(context));
                            },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(strings.renameActive),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.profiles.length <= 1 ||
                              controller.activeProfile == null
                          ? null
                          : () {
                              unawaited(_confirmDeleteActiveProfile(context));
                            },
                      icon: const Icon(Icons.person_remove_outlined),
                      label: Text(strings.deleteActive),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: strings.appearance,
            icon: Icons.palette_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.theme),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AppThemeMode>(
                  segments: <ButtonSegment<AppThemeMode>>[
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(strings.system),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(strings.light),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(strings.dark),
                    ),
                  ],
                  selected: <AppThemeMode>{settings.themeMode},
                  onSelectionChanged: (Set<AppThemeMode> selected) {
                    unawaited(
                      _saveSettings(
                        context,
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
            title: strings.accessibility,
            icon: Icons.accessibility_new,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.largeText),
                  subtitle: Text(strings.largeTextDescription),
                  value: settings.largeText,
                  onChanged: (bool value) {
                    unawaited(
                      _saveSettings(
                        context,
                        settings.copyWith(largeText: value),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.reducedMotion),
                  subtitle: Text(strings.reducedMotionDescription),
                  value: settings.reducedMotion,
                  onChanged: (bool value) {
                    unawaited(
                      _saveSettings(
                        context,
                        settings.copyWith(reducedMotion: value),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.screenReaderHints),
                  subtitle: Text(strings.screenReaderHintsDescription),
                  value: settings.screenReaderHints,
                  onChanged: (bool value) {
                    unawaited(
                      _saveSettings(
                        context,
                        settings.copyWith(screenReaderHints: value),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.confirmBeforeLeavingQuiz),
                  subtitle: Text(strings.confirmBeforeLeavingQuizDescription),
                  value: settings.confirmBeforeExitQuiz,
                  onChanged: (bool value) {
                    unawaited(
                      _saveSettings(
                        context,
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
            title: strings.privacyAndData,
            icon: Icons.shield_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.privacyOfflineDescription),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  label: strings.readPrivacyDetails,
                  value: 'PRIVACY.md',
                  uri: Uri.parse(AppConstants.privacyUrl),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_toggle_off),
                  title: Text(strings.clearActiveProfileActivity),
                  subtitle: Text(strings.clearActivityDescription),
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
                    strings.resetAllLocalData,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  subtitle: Text(strings.resetAllDataDescription),
                  onTap: () {
                    unawaited(_confirmResetAll(context));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: strings.updates,
            icon: Icons.system_update_alt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${strings.installedVersion}: ${AppConstants.version}'),
                const SizedBox(height: AppSpacing.sm),
                Text(strings.updateDescription),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.new_releases_outlined,
                  label: strings.viewGitHubReleases,
                  value: AppConstants.releasesUrl,
                  uri: Uri.parse(AppConstants.releasesUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: strings.about,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${AppConstants.appName} ${AppConstants.version}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(strings.aboutDescription),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const AboutPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: Text(strings.about),
                ),
                const SizedBox(height: AppSpacing.md),
                _LinkTile(
                  icon: Icons.code,
                  label: strings.githubRepository,
                  value: AppConstants.githubUrl,
                  uri: Uri.parse(AppConstants.githubUrl),
                ),
                _LinkTile(
                  icon: Icons.security_outlined,
                  label: strings.securityPolicy,
                  value: 'SECURITY.md',
                  uri: Uri.parse(AppConstants.securityUrl),
                ),
                _LinkTile(
                  icon: Icons.volunteer_activism_outlined,
                  label: strings.buyMeACoffee,
                  value: AppConstants.buyMeACoffeeUrl,
                  uri: Uri.parse(AppConstants.buyMeACoffeeUrl),
                ),
                _LinkTile(
                  icon: Icons.business_center_outlined,
                  label: strings.businessEmail,
                  value: AppConstants.businessEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.businessEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge'},
                  ),
                ),
                _LinkTile(
                  icon: Icons.email_outlined,
                  label: strings.businessEmailTwo,
                  value: AppConstants.secondaryBusinessEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.secondaryBusinessEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge'},
                  ),
                ),
                _LinkTile(
                  icon: Icons.support_agent_outlined,
                  label: strings.supportEmail,
                  value: AppConstants.supportEmail,
                  uri: Uri(
                    scheme: 'mailto',
                    path: AppConstants.supportEmail,
                    queryParameters: <String, String>{'subject': 'QuizForge support'},
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.madeBySanskar,
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
    final AppLocalizations strings = AppLocalizations.of(context);
    final String? name = await _askForProfileName(
      context,
      title: strings.addLocalProfile,
      actionLabel: strings.add,
    );
    if (name == null || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.createProfile(name),
      successMessage: strings.profileCreated,
    );
  }

  Future<void> _showRenameProfileDialog(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final PlayerProfile? current = controller.activeProfile;
    if (current == null) {
      return;
    }
    final String? name = await _askForProfileName(
      context,
      title: strings.renameActiveProfile,
      actionLabel: strings.rename,
      initialValue: current.displayName,
    );
    if (name == null || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.renameActiveProfile(name),
      successMessage: strings.profileRenamed,
    );
  }

  Future<String?> _askForProfileName(
    BuildContext context, {
    required String title,
    required String actionLabel,
    String initialValue = '',
  }) async {
    final AppLocalizations strings = AppLocalizations.of(context);
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
              decoration: InputDecoration(labelText: strings.displayName),
              onSubmitted: (String value) {
                if (value.trim().length >= 2) {
                  Navigator.of(dialogContext).pop(value.trim());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(strings.cancel),
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
    final AppLocalizations strings = AppLocalizations.of(context);
    final PlayerProfile? profile = controller.activeProfile;
    if (profile == null || controller.profiles.length <= 1) {
      return;
    }
    final bool confirmed = await _confirm(
      context,
      title: strings.deleteActiveProfileTitle,
      message: strings.deleteActiveProfileDescription,
      confirmLabel: strings.deleteProfile,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: () => controller.deleteProfile(profile.id),
      successMessage: strings.profileDeleted,
    );
  }

  Future<void> _confirmClearActivity(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool confirmed = await _confirm(
      context,
      title: strings.clearActivityTitle,
      message: strings.clearActivityConfirmDescription,
      confirmLabel: strings.clearActivity,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: controller.clearActiveProfileActivity,
      successMessage: strings.activityCleared,
    );
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool confirmed = await _confirm(
      context,
      title: strings.resetAllTitle,
      message: strings.resetAllConfirmDescription,
      confirmLabel: strings.resetEverything,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      action: controller.resetAllLocalData,
      successMessage: strings.resetCompleted,
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(strings.cancel),
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

  Future<void> _saveSettings(
    BuildContext context,
    AppSettings nextSettings,
  ) {
    return _runSilentAction(
      context,
      action: () => controller.updateSettings(nextSettings),
      failureEvent: 'settings.persist.failed',
    );
  }

  Future<void> _runSilentAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String failureEvent,
  }) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      await action();
    } on Object catch (error) {
      controller.logger.error(
        failureEvent,
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.actionFailed)),
        );
      }
    }
  }

  Future<void> _runAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } on Object catch (error) {
      controller.logger.error(
        'settings.action.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.actionFailed)),
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
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
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).linkOpenFailed(value)),
        ),
      );
    }
  }
}
