import 'package:flutter/material.dart';

import 'application/quizforge_controller.dart';
import 'core/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'domain/app_settings.dart';
import 'presentation/home_page.dart';

final class QuizForgeApp extends StatelessWidget {
  const QuizForgeApp({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final AppSettings settings = controller.settings;
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode(settings.themeMode),
          themeAnimationDuration:
              settings.reducedMotion ? Duration.zero : const Duration(milliseconds: 200),
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData media = MediaQuery.of(context);
            final TextScaler scaler = settings.largeText
                ? const TextScaler.linear(1.15)
                : media.textScaler;
            return MediaQuery(
              data: media.copyWith(
                textScaler: scaler,
                disableAnimations: media.disableAnimations || settings.reducedMotion,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: _home(),
        );
      },
    );
  }

  Widget _home() {
    if (controller.loading) {
      return const _LoadingPage();
    }
    if (controller.errorMessage != null) {
      return _ErrorPage(
        message: controller.errorMessage!,
        onRetry: controller.initialize,
      );
    }
    return HomePage(controller: controller);
  }

  static ThemeMode _themeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

final class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Semantics(
          label: 'Loading QuizForge',
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

final class _ErrorPage extends StatelessWidget {
  const _ErrorPage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'QuizForge could not start',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
