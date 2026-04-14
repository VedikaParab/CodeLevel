class AssessmentQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  AssessmentQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    final opts = <String>[];
    if (json['options'] is List) {
      for (final o in json['options']) {
        opts.add(o?.toString() ?? '');
      }
    }

    return AssessmentQuestion(
      question: json['question']?.toString() ?? '',
      options: opts,
      correctIndex: json['correct_index'] is int
          ? json['correct_index'] as int
          : int.tryParse(json['correct_index']?.toString() ?? '') ?? 0,
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}
