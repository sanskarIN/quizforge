import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/question_bank_codec.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  const QuestionBankCodec codec = QuestionBankCodec();
  final List<Question> bank = <Question>[
    Question(
      id: 'q1',
      type: QuestionType.multipleChoice,
      prompt: 'Pick, the "quoted" answer?',
      choices: const <String>['A', 'B, C'],
      correctAnswers: const <String>{'A'},
      category: 'Demo',
      difficulty: Difficulty.medium,
      tags: const <String>['csv', 'json'],
      explanation: 'A line with punctuation, commas, and "quotes".',
      timeLimitSeconds: 45,
    ),
    Question(
      id: 'q2',
      type: QuestionType.shortAnswer,
      prompt: 'What is two plus two?',
      correctAnswers: const <String>{'4', 'four'},
      category: 'Math',
      difficulty: Difficulty.easy,
    ),
  ];

  test('JSON round trip preserves question fields', () {
    final String encoded = codec.encodeJson(bank);
    final QuestionBankImportResult result = codec.decodeJson(encoded);

    expect(result.errors, isEmpty);
    expect(result.duplicates, isEmpty);
    expect(result.questions, hasLength(2));
    expect(result.questions.first.toJson(), bank.first.toJson());
    expect(result.questions.last.toJson(), bank.last.toJson());
  });

  test('CSV round trip handles commas and quotes', () {
    final String encoded = codec.encodeCsv(bank);
    final QuestionBankImportResult result = codec.decodeCsv(encoded);

    expect(result.errors, isEmpty);
    expect(result.duplicates, isEmpty);
    expect(result.questions, hasLength(2));
    expect(result.questions.first.toJson(), bank.first.toJson());
  });

  test('import reports duplicates against existing bank', () {
    final String encoded = codec.encodeJson(<Question>[bank.first]);
    final QuestionBankImportResult result = codec.decodeJson(
      encoded,
      existing: <Question>[bank.first],
    );

    expect(result.questions, isEmpty);
    expect(result.duplicates, hasLength(1));
  });

  test('JSON import rejects normalized duplicate accepted answers', () {
    final QuestionBankImportResult result = codec.decodeJson(
      '{"questions":[{'
      '"id":"duplicate-json",'
      '"type":"shortAnswer",'
      '"prompt":"Provide an answer.",'
      '"correctAnswers":["Alpha"," alpha "],'
      '"category":"Testing",'
      '"difficulty":"easy"'
      '}]}',
    );

    expect(result.questions, isEmpty);
    expect(result.errors.single, contains('non-empty and unique'));
  });

  test('CSV import rejects normalized duplicate accepted answers', () {
    final QuestionBankImportResult result = codec.decodeCsv(
      'id,type,prompt,choices,correctAnswers,category,difficulty,tags,explanation,timeLimitSeconds\n'
      'duplicate-csv,shortAnswer,Provide an answer.,[],"[""Alpha"","" alpha ""]",Testing,easy,[],,',
    );

    expect(result.questions, isEmpty);
    expect(result.errors.single, contains('non-empty and unique'));
  });

  test('malformed JSON is reported without throwing', () {
    final QuestionBankImportResult result = codec.decodeJson('{not-json');

    expect(result.isSuccess, isFalse);
    expect(result.errors, isNotEmpty);
  });

  test('malformed CSV quoting is reported without throwing', () {
    final QuestionBankImportResult result = codec.decodeCsv(
      'id,type,prompt,choices,correctAnswers,category,difficulty,tags,explanation,timeLimitSeconds\n'
      'q1,shortAnswer,"unclosed',
    );

    expect(result.isSuccess, isFalse);
    expect(result.errors.single, contains('Unclosed quoted field'));
  });

  test('quote inside unquoted CSV field is rejected', () {
    final QuestionBankImportResult result = codec.decodeCsv(
      'id,type,prompt,choices,correctAnswers,category,difficulty,tags,explanation,timeLimitSeconds\n'
      'q1,shortAnswer,bad"quote,[],["answer"],Demo,easy,[],Explanation,',
    );

    expect(result.isSuccess, isFalse);
    expect(
      result.errors.single,
      contains('Unexpected quote in unquoted field'),
    );
  });

  test('characters after closing quoted CSV field are rejected', () {
    final QuestionBankImportResult result = codec.decodeCsv(
      'id,type,prompt,choices,correctAnswers,category,difficulty,tags,explanation,timeLimitSeconds\n'
      'q1,shortAnswer,"prompt"suffix,[],["answer"],Demo,easy,[],Explanation,',
    );

    expect(result.isSuccess, isFalse);
    expect(
      result.errors.single,
      contains('Unexpected character after closing quoted field'),
    );
  });

  test('oversized import payloads are rejected before parsing', () {
    final String chunk = List<String>.filled(1024, 'x').join();
    final int chunkCount =
        (QuestionBankCodec.maxSourceCharacters ~/ chunk.length) + 2;
    final String oversized = List<String>.filled(chunkCount, chunk).join();

    expect(
      oversized.length,
      greaterThan(QuestionBankCodec.maxSourceCharacters),
    );
    expect(
      codec.decodeJson(oversized).errors.single,
      contains('maximum supported import size'),
    );
    expect(
      codec.decodeCsv(oversized).errors.single,
      contains('maximum supported import size'),
    );
  });

  test('JSON question count limit is enforced before item parsing', () {
    final String rows = List<String>.filled(
      QuestionBankCodec.maxQuestions + 1,
      '{}',
    ).join(',');
    final String source = '{"questions":[$rows]}';

    final QuestionBankImportResult result = codec.decodeJson(source);

    expect(result.questions, isEmpty);
    expect(result.errors.single, contains('${QuestionBankCodec.maxQuestions}'));
  });
}
