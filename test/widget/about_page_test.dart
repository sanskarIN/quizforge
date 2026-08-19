import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/presentation/about_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('shows project identity contacts funding and credit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const AboutPage()));

    expect(find.text('QuizForge'), findsWidgets);
    expect(find.text('Installed version: 0.1.0'), findsOneWidget);
    expect(find.text('GitHub repository'), findsOneWidget);
    expect(find.text('Buy Me a Coffee'), findsOneWidget);
    expect(find.text('sanskarin@outlook.in'), findsOneWidget);
    expect(find.text('sanskarin.business@gmail.com'), findsOneWidget);
    expect(find.text('supportramsandesh@gmail.com'), findsOneWidget);
    expect(find.text('Made by the Sanskar'), findsOneWidget);
  });
}
