import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/presentation/onboarding_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('moves through onboarding and completes', (WidgetTester tester) async {
    int completed = 0;

    await tester.pumpWidget(
      buildTestApp(
        OnboardingPage(
          onComplete: () async {
            completed += 1;
          },
        ),
      ),
    );

    expect(find.text('Learn and play offline'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Practice your way'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Review, improve, repeat'), findsOneWidget);

    await tester.tap(find.text('Start QuizForge'));
    await tester.pump();
    expect(completed, 1);
  });
}
