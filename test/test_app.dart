import 'package:flutter/material.dart';
import 'package:quizforge/l10n/app_localizations.dart';

Widget buildTestApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
