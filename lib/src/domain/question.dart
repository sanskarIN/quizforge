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

  static const int maxIdLength = 120;
  static const int maxPromptLength = 2000;
  static const int maxCategoryLength = 120;
  static const int maxChoices = 20;
  static const int maxChoiceLength = 500;
  static const int maxCorrectAnswers = 20;
  static const int maxAnswerLength = 500;
  static const int maxTags = 20;
  static const int maxTagLength = 80;
  static const int maxExplanationLength = 5000;
  static const int maxTimeLimitSeconds = 3600;

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
    final String trimmedId = id.trim();
    final String trimmedPrompt = prompt.trim();
    final String trimmedCategory = category.trim();

    if (trimmedId.isEmpty) {
      errors.add('Question id is required.');
    } else if (trimmedId.length > maxIdLength) {
      errors.add('Question id must be at most $maxIdLength characters.');
    }

    if (trimmedPrompt.length < 3) {
      errors.add('Prompt must contain at least 3 characters.');
    } else if (trimmedPrompt.length > maxPromptLength) {
      errors.add('Prompt must be at most $maxPromptLength characters.');
    }

    if (trimmedCategory.isEmpty) {
      errors.add('Category is required.');
    } else if (trimmedCategory.length > maxCategoryLength) {
      errors.add('Category must be at most $maxCategoryLength characters.');
    }

    if (correctAnswers.isEmpty) {
      errors.add('At least one correct answer is required.');
    }
    if (correctAnswers.length > maxCorrectAnswers) {
      errors.add('A question supports at most $maxCorrectAnswers correct answers.');
    }
    if (choices.length > maxChoices) {
      errors.add('A question supports at most $maxChoices choices.');
    }
    if (tags.length > maxTags) {
      errors.add('A question supports at most $maxTags tags.');
    }
    if (explanation.length > maxExplanationLength) {
      errors.add(
        'Explanation must be at most $maxExplanationLength characters.',
      );
    }
    if (timeLimitSeconds != null && timeLimitSeconds! <= 0) {
      errors.add('Time limit must be greater than zero.');
    } else if (timeLimitSeconds != null &&
        timeLimitSeconds! > maxTimeLimitSeconds) {
      errors.add('Time limit must not exceed $maxTimeLimitSeconds seconds.');
    }

    final Set<String> normalizedChoices = choices
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (normalizedChoices.length != choices.length) {
      errors.add('Choices must be non-empty and unique.');
    }
    if (choices.any((String choice) => choice.length > maxChoiceLength)) {
      errors.add('Each choice must be at most $maxChoiceLength characters.');
    }

    final Set<String> normalizedAnswers = correctAnswers
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (normalizedAnswers.length != correctAnswers.length) {
      errors.add('Correct answers must be non-empty and unique.');
    }
    if (correctAnswers.any((String answer) => answer.length > maxAnswerLength)) {
      errors.add('Each correct answer must be at most $maxAnswerLength characters.');
    }

    final Set<String> normalizedTags = tags
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (normalizedTags.length != tags.length) {
      errors.add('Tags must be non-empty and unique.');
    }
    if (tags.any((String tag) => tag.length > maxTagLength)) {
      errors.add('Each tag must be at most $maxTagLength characters.');
    }

    switch (type) {
      case QuestionType.multipleChoice:
        if (choices.length < 2) {
          errors.add('Multiple-choice questions need at least two choices.');
        }
        if (correctAnswers.length != 1) {
          errors.add('Multiple-choice questions need exactly one correct answer.');
        }
        break;
      case QuestionType.trueFalse:
        if (choices.isNotEmpty) {
          errors.add('True/false questions must not define custom choices.');
        }
        if (correctAnswers.length != 1) {
          errors.add('True/false questions need exactly one correct answer.');
        }
        final String answer = normalizeAnswer(correctAnswers.firstOrNull ?? '');
        if (answer != 'true' && answer != 'false') {
          errors.add('True/false answer must be true or false.');
        }
        break;
      case QuestionType.multiSelect:
        if (choices.length < 2) {
          errors.add('Multi-select questions need at least two choices.');
        }
        if (correctAnswers.length < 2) {
          errors.add('Multi-select questions need at least two correct answers.');
        }
        break;
      case QuestionType.shortAnswer:
        if (choices.isNotEmpty) {
          errors.add('Short-answer questions must not define choices.');
        }
        break;
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
    final List<String> correctAnswers = _stringList(rawCorrectAnswers);
    final Set<String> normalizedCorrectAnswers = correctAnswers
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (normalizedCorrectAnswers.length != correctAnswers.length) {
      throw const FormatException(
        'Correct answers must be non-empty and unique.',
      );
    }
    return Question(
      id: _requiredString(json, 'id'),
      type: QuestionType.values.byName(_requiredString(json, 'type')),
      prompt: _requiredString(json, 'prompt'),
      choices: _stringList(rawChoices),
      correctAnswers: correctAnswers.toSet(),
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