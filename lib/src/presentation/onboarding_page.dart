import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

final class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

final class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<_OnboardingStep> steps = <_OnboardingStep>[
      _OnboardingStep(
        icon: Icons.offline_bolt_outlined,
        title: strings.onboardingStepOneTitle,
        description: strings.onboardingStepOneDescription,
      ),
      _OnboardingStep(
        icon: Icons.auto_awesome_outlined,
        title: strings.onboardingStepTwoTitle,
        description: strings.onboardingStepTwoDescription,
      ),
      _OnboardingStep(
        icon: Icons.accessibility_new,
        title: strings.onboardingStepThreeTitle,
        description: strings.onboardingStepThreeDescription,
      ),
    ];
    final bool lastPage = _page == steps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    strings.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finishing ? null : () => unawaited(_finish()),
                    child: Text(strings.onboardingSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (int value) => setState(() => _page = value),
                itemBuilder: (BuildContext context, int index) {
                  return _StepView(step: steps[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: <Widget>[
                  Semantics(
                    label: '${_page + 1} / ${steps.length}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        steps.length,
                        (int index) => AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      if (_page > 0)
                        OutlinedButton.icon(
                          onPressed: _finishing ? null : _previous,
                          icon: const Icon(Icons.arrow_back),
                          label: Text(strings.back),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _finishing
                            ? null
                            : lastPage
                            ? () => unawaited(_finish())
                            : _next,
                        icon: Icon(
                          lastPage ? Icons.check : Icons.arrow_forward,
                        ),
                        label: Text(
                          _finishing
                              ? strings.onboardingStarting
                              : lastPage
                              ? strings.onboardingStart
                              : strings.next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    _pageController.previousPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_finishing) {
      return;
    }
    setState(() => _finishing = true);
    try {
      await widget.onComplete();
    } finally {
      if (mounted) {
        setState(() => _finishing = false);
      }
    }
  }
}

final class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Icon(
                    step.icon,
                    size: 72,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
