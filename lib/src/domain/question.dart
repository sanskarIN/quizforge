enum QuestionType {
  multipleChoice,
  trueFalse,
  multiSelect,
  shortAnswer,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

final class Question {
  Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswers,
    required this.category,
    required this.difficulty,
    this.choices = const <String>[],
    this.tags = const <String>[],
    this.explanation = '',
    this.timeLimitSeconds,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String> choices;
  final Set<String> correctAnswers;
  final String category;
  final Difficulty difficulty;
  final List<String> tags;
  final String explanation;
  final int? timeLimitSeconds;

  List<String> validate() {
    final List<String> errors = <String>[];
    if (id.trim().isEmpty) {
      errors.add('Question id is required.');
    }
    if (prompt.trim().length < 3) {
      errors.add('Prompt must contain at least 3 characters.');
    }
    if (category.trim().isEmpty) {
      errors.add('Category is required.');
    }
    if (correctAnswers.isEmpty) {
      errors.add('At least one correct answer is required.');
    }
    if (timeLimitSeconds != null && timeLimitSeconds! <= 0) {
      errors.add('Time limit must be greater than zero.');
    }

    final Set<String> normalizedChoices = choices
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (normalizedChoices.length != choices.length) {
      errors.add('Choices must be non-empty and unique.');
    }

    switch (type) {
      case QuestionType.multipleChoice:
        if (choices.length < 2) {
          errors.add('Multiple-choice questions need at least two choices.');
        }
        if (correctAnswers.length != 1) {
          errors.add('Multiple-choice questions need exactly one correct answer.');
        }
      case QuestionType.trueFalse:
        if (correctAnswers.length != 1) {
          errors.add('True/false questions need exactly one correct answer.');
        }
        final String answer = normalizeAnswer(correctAnswers.firstOrNull ?? '');
        if (answer != 'true' && answer != 'false') {
          errors.add('True/false answer must be true or false.');
        }
      case QuestionType.multiSelect:
        if (choices.length < 2) {
          errors.add('Multi-select questions need at least two choices.');
        }
        if (correctAnswers.length < 2) {
          errors.add('Multi-select questions need at least two correct answers.');
        }
      case QuestionType.shortAnswer:
        if (choices.isNotEmpty) {
          errors.add('Short-answer questions must not define choices.');
        }
    }

    if (type == QuestionType.multipleChoice || type == QuestionType.multiSelect) {
      for (final String answer in correctAnswers) {
        if (!normalizedChoices.contains(normalizeAnswer(answer))) {
          errors.add('Correct answer "$answer" is not one of the choices.');
        }
      }
    }

    return errors;
  }

  String get fingerprint {
    final String normalizedPrompt = normalizeAnswer(prompt);
    final String normalizedCategory = normalizeAnswer(category);
    return '$normalizedCategory|${type.name}|$normalizedPrompt';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': type.name,
        'prompt': prompt,
        'choices': choices,
        'correctAnswers': correctAnswers.toList()..sort(),
        'category': category,
        'difficulty': difficulty.name,
        'tags': tags,
        'explanation': explanation,
        'timeLimitSeconds': timeLimitSeconds,
      };

  static Question fromJson(Map<String, Object?> json) {
    final Object? rawChoices = json['choices'];
    final Object? rawCorrectAnswers = json['correctAnswers'];
    final Object? rawTags = json['tags'];
    return Question(
      id: _requiredString(json, 'id'),
      type: QuestionType.values.byName(_requiredString(json, 'type')),
      prompt: _requiredString(json, 'prompt'),
      choices: _stringList(rawChoices),
      correctAnswers: _stringList(rawCorrectAnswers).toSet(),
      category: _requiredString(json, 'category'),
      difficulty: Difficulty.values.byName(_requiredString(json, 'difficulty')),
      tags: _stringList(rawTags),
      explanation: (json['explanation'] as String?) ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
    );
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected non-empty string for "$key".');
    }
    return value;
  }

  static List<String> _stringList(Object? value) {
    if (value == null) {
      return <String>[];
    }
    if (value is! List<Object?>) {
      throw const FormatException('Expected a list of strings.');
    }
    return value.map((Object? item) {
      if (item is! String) {
        throw const FormatException('Expected a list of strings.');
      }
      return item;
    }).toList(growable: false);
  }
}

String normalizeAnswer(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ');

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
