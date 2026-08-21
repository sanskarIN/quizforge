import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/app.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/onboarding_repository.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/app_settings.dart';

void main() {
  testWidgets('shows onboarding when first-run preference is incomplete', (
    WidgetTester tester,
  ) async {
    final _ControllerFixture fixture = await _buildController();
    addTearDown(fixture.database.close);
    final _FakeOnboardingStore onboarding = _FakeOnboardingStore();

    await tester.pumpWidget(
      QuizForgeApp(controller: fixture.controller, onboardingStore: onboarding),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learn and play offline'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('skipping onboarding persists completion and opens dashboard', (
    WidgetTester tester,
  ) async {
    final _ControllerFixture fixture = await _buildController();
    addTearDown(fixture.database.close);
    final _FakeOnboardingStore onboarding = _FakeOnboardingStore();

    await tester.pumpWidget(
      QuizForgeApp(controller: fixture.controller, onboardingStore: onboarding),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(onboarding.completed, isTrue);
    expect(find.text('Ready to forge your next score?'), findsOneWidget);
  });

  testWidgets('completed onboarding opens dashboard directly', (
    WidgetTester tester,
  ) async {
    final _ControllerFixture fixture = await _buildController();
    addTearDown(fixture.database.close);
    final _FakeOnboardingStore onboarding = _FakeOnboardingStore(
      completed: true,
    );

    await tester.pumpWidget(
      QuizForgeApp(controller: fixture.controller, onboardingStore: onboarding),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to forge your next score?'), findsOneWidget);
    expect(find.text('Learn and play offline'), findsNothing);
  });

  testWidgets('onboarding preference load failure does not trap startup', (
    WidgetTester tester,
  ) async {
    final _ControllerFixture fixture = await _buildController();
    addTearDown(fixture.database.close);
    final _FakeOnboardingStore onboarding = _FakeOnboardingStore(
      failLoads: true,
    );

    await tester.pumpWidget(
      QuizForgeApp(controller: fixture.controller, onboardingStore: onboarding),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to forge your next score?'), findsOneWidget);
    expect(find.text('Learn and play offline'), findsNothing);
  });
}

Future<_ControllerFixture> _buildController() async {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  final QuizForgeController controller = QuizForgeController(
    database: database,
    questionRepository: QuestionRepository(database),
    settingsRepository: _FakeSettingsStore(),
    profilePreferences: _FakeProfilePreferences(),
  );
  await controller.initialize();
  return _ControllerFixture(database: database, controller: controller);
}

final class _ControllerFixture {
  const _ControllerFixture({required this.database, required this.controller});

  final AppDatabase database;
  final QuizForgeController controller;
}

final class _FakeOnboardingStore implements OnboardingStore {
  _FakeOnboardingStore({this.completed = false, this.failLoads = false});

  bool completed;
  bool failLoads;

  @override
  Future<bool> isCompleted() async {
    if (failLoads) {
      throw StateError('simulated onboarding preference load failure');
    }
    return completed;
  }

  @override
  Future<void> markCompleted() async {
    completed = true;
  }

  @override
  Future<void> reset() async {
    completed = false;
  }
}

final class _FakeSettingsStore implements AppSettingsStore {
  AppSettings value = const AppSettings();

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> reset() async {
    value = const AppSettings();
  }

  @override
  Future<void> save(AppSettings settings) async {
    value = settings;
  }
}

final class _FakeProfilePreferences implements ActiveProfilePreferences {
  String? activeProfileId;

  @override
  Future<void> clearActiveProfileId() async {
    activeProfileId = null;
  }

  @override
  Future<String?> loadActiveProfileId() async => activeProfileId;

  @override
  Future<void> saveActiveProfileId(String profileId) async {
    activeProfileId = profileId;
  }
}
