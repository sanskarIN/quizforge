import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/application/quizforge_controller.dart';
import 'src/data/app_database.dart';
import 'src/data/profile_preferences.dart';
import 'src/data/question_repository.dart';
import 'src/data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDatabase database = AppDatabase.defaults();
  final QuizForgeController controller = QuizForgeController(
    database: database,
    questionRepository: QuestionRepository(database),
    settingsRepository: SettingsRepository(),
    profilePreferences: ProfilePreferences(),
  );

  await controller.initialize();
  runApp(QuizForgeApp(controller: controller));
}
