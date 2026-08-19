import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/question_bank_codec.dart';

void main() {
  const QuestionBankCodec codec = QuestionBankCodec();

  test('random malformed JSON never escapes parser exceptions', () {
    final Random random = Random(20260819);
    const String alphabet = '{}[],:"abc123 truefalse\n\r\\';

    for (int sample = 0; sample < 500; sample += 1) {
      final int length = random.nextInt(160);
      final String source = List<String>.generate(
        length,
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();

      expect(
        () => codec.decodeJson(source),
        returnsNormally,
        reason: 'JSON sample $sample escaped a parser exception.',
      );
    }
  });

  test('random malformed CSV never escapes parser exceptions', () {
    final Random random = Random(19082026);
    const String alphabet = 'abc123,\"[]{}\n\r\\ ';

    for (int sample = 0; sample < 500; sample += 1) {
      final int length = random.nextInt(220);
      final String source = List<String>.generate(
        length,
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();

      expect(
        () => codec.decodeCsv(source),
        returnsNormally,
        reason: 'CSV sample $sample escaped a parser exception.',
      );
    }
  });
}
