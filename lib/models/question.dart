class Question {
  final String id;
  final String category;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;
  final bool isPremium;

  Question({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.isPremium,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'].toString(),
      category: json['category'].toString(),
      question: json['question'].toString(),
      options: json['options'].toString().split('|'),
      correctAnswer: json['correctAnswer'].toString(),
      explanation: json['explanation'].toString(),
      difficulty: json['difficulty'].toString(),
      isPremium: json['isPremium'].toString().toLowerCase() == 'true',
    );
  }
}
