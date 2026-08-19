import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'application/quizforge_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/onboarding_repository.dart';
import 'domain/app_settings.dart';
import 'presentation/home_page.dart';
import 'presentation/onboarding_page.dart';

final class QuizForgeApp extends StatefulWidget {
  const QuizForgeApp({
    required this.controller,
    this.onboardingStore,
    super.key,
  });

  final QuizForgeController controller;
  final OnboardingStore? onboardingStore;

  @override
  State<QuizForgeApp> createState() => _QuizForgeAppState();
}

final class _QuizForgeAppState extends State<QuizForgeApp> {
  late final OnboardingStore _onboardingStore;
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _onboardingStore = widget.onboardingStore ?? OnboardingRepository();
    _loadOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final AppSettings settings = widget.controller.settings;
        return MaterialApp(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode(settings.themeMode),
          themeAnimationDuration: settings.reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 200),
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData media = MediaQuery.of(context);
            final double systemScaleAtBody = media.textScaler.scale(14) / 14;
            final TextScaler scaler =
                settings.largeText && systemScaleAtBody < 1.15
                    ? const TextScaler.linear(1.15)
                    : media.textScaler;
            return MediaQuery(
              data: media.copyWith(
                textScaler: scaler,
                disableAnimations:
                    media.disableAnimations || settings.reducedMotion,
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
    if (widget.controller.loading || _onboardingComplete == null) {
      return const _LoadingPage();
    }
    if (widget.controller.errorMessage != null) {
      return _ErrorPage(onRetry: widget.controller.initialize);
    }
    if (!_onboardingComplete!) {
      return OnboardingPage(onComplete: _completeOnboarding);
    }
    return HomePage(controller: widget.controller);
  }

  Future<void> _loadOnboarding() async {
    try {
      final bool completed = await _onboardingStore.isCompleted();
      if (mounted) {
        setState(() => _onboardingComplete = completed);
      }
    } on Object catch (error) {
      widget.controller.logger.warning(
        'onboarding.load.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        setState(() => _onboardingComplete = true);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      await _onboardingStore.markCompleted();
    } on Object catch (error) {
      widget.controller.logger.warning(
        'onboarding.persist.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
    }
    if (mounted) {
      setState(() => _onboardingComplete = true);
    }
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
    final AppLocalizations strings = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: strings.loadingQuizForge,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

final class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
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
                    strings.startupErrorTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(strings.tryAgain),
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
