import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/app_constants.dart';
import '../core/theme/app_theme.dart';

final class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.about)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: <Widget>[
                            const Icon(Icons.quiz_outlined, size: 64),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${strings.installedVersion}: ${AppConstants.version}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              strings.aboutDescription,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              strings.madeBySanskar,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: <Widget>[
                            _AboutLinkTile(
                              icon: Icons.code,
                              label: strings.githubRepository,
                              value: AppConstants.githubUrl,
                              uri: Uri.parse(AppConstants.githubUrl),
                            ),
                            _AboutLinkTile(
                              icon: Icons.security_outlined,
                              label: strings.securityPolicy,
                              value: 'SECURITY.md',
                              uri: Uri.parse(AppConstants.securityUrl),
                            ),
                            _AboutLinkTile(
                              icon: Icons.volunteer_activism_outlined,
                              label: strings.buyMeACoffee,
                              value: AppConstants.buyMeACoffeeUrl,
                              uri: Uri.parse(AppConstants.buyMeACoffeeUrl),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: <Widget>[
                            _AboutLinkTile(
                              icon: Icons.business_center_outlined,
                              label: strings.businessEmail,
                              value: AppConstants.businessEmail,
                              uri: _mailUri(
                                AppConstants.businessEmail,
                                'QuizForge',
                              ),
                            ),
                            _AboutLinkTile(
                              icon: Icons.email_outlined,
                              label: strings.businessEmailTwo,
                              value: AppConstants.secondaryBusinessEmail,
                              uri: _mailUri(
                                AppConstants.secondaryBusinessEmail,
                                'QuizForge',
                              ),
                            ),
                            _AboutLinkTile(
                              icon: Icons.support_agent_outlined,
                              label: strings.supportEmail,
                              value: AppConstants.supportEmail,
                              uri: _mailUri(
                                AppConstants.supportEmail,
                                'QuizForge support',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Uri _mailUri(String address, String subject) => Uri(
        scheme: 'mailto',
        path: address,
        queryParameters: <String, String>{'subject': subject},
      );
}

final class _AboutLinkTile extends StatelessWidget {
  const _AboutLinkTile({
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
