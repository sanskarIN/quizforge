import 'package:quizforge/src/data/profile_selection_store.dart';
import 'package:quizforge/src/data/question_store.dart';
import 'package:quizforge/src/data/settings_store.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/question.dart';

final class FakeQuestionStore implements QuestionStore {
  FakeQuestionStore([Iterable<Question> seed = const <Question>[]])
      : _questions = List<Question>.of(seed);

  List<Question> _questions;
  bool failLoad = false;
  bool failSave = false;

  @override
  Future<List<Question>> loadAll() async {
    if (failLoad) {
      throw StateError('question load failed');
    }
    return List<Question>.unmodifiable(_questions);
  }

  @override
  Future<void> saveAll(Iterable<Question> questions) async {
    if (failSave) {
      throw StateError('question save failed');
    }
    _questions = <Question>[..._questions, ...questions];
  }
}

final class FakeSettingsStore implements SettingsStore {
  FakeSettingsStore([this.value = const AppSettings()]);

  AppSettings value;
  bool failLoad = false;
  bool failSave = false;
  int resetCount = 0;

  @override
  Future<AppSettings> load() async {
    if (failLoad) {
      throw StateError('settings load failed');
    }
    return value;
  }

  @override
  Future<void> save(AppSettings settings) async {
    if (failSave) {
      throw StateError('settings save failed');
    }
    value = settings;
  }

  @override
  Future<void> reset() async {
    resetCount += 1;
    value = const AppSettings();
  }
}

final class FakeProfileSelectionStore implements ProfileSelectionStore {
  FakeProfileSelectionStore({this.activeProfileId});

  String? activeProfileId;
  bool failSave = false;
  int clearCount = 0;

  @override
  Future<String?> loadActiveProfileId() async => activeProfileId;

  @override
  Future<void> saveActiveProfileId(String profileId) async {
    if (failSave) {
      throw StateError('profile selection save failed');
    }
    activeProfileId = profileId;
  }

  @override
  Future<void> clearActiveProfileId() async {
    clearCount += 1;
    activeProfileId = null;
  }
}
