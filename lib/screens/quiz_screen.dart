import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;
  bool answered = false;
  bool isLoading = true;

  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final allQuestions = await QuestionService().loadQuestions();

    final filteredQuestions = allQuestions
        .where((q) => q.category == widget.category)
        .toList();

    setState(() {
      questions = filteredQuestions;
      isLoading = false;
    });
  }

  void selectAnswer(int index) {
    if (answered) return;

    final currentQuestion = questions[currentQuestionIndex];
    final selectedAnswer = currentQuestion.options[index];

    setState(() {
      selectedAnswerIndex = index;
      answered = true;

      if (selectedAnswer == currentQuestion.correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        answered = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            totalQuestions: questions.length,
            category: widget.category,
          ),
        ),
      );
    }
  }

  Color getAnswerColor(int index) {
    if (!answered) return Colors.white;

    final currentQuestion = questions[currentQuestionIndex];
    final answer = currentQuestion.options[index];

    if (answer == currentQuestion.correctAnswer) {
      return Colors.green.shade100;
    }

    if (index == selectedAnswerIndex) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  IconData? getAnswerIcon(int index) {
    if (!answered) return null;

    final currentQuestion = questions[currentQuestionIndex];
    final answer = currentQuestion.options[index];

    if (answer == currentQuestion.correctAnswer) {
      return Icons.check_circle;
    }

    if (index == selectedAnswerIndex) {
      return Icons.cancel;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.category} Quiz')),
        body: const Center(
          child: Text(
            'No questions found for this category.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final answers = currentQuestion.options;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('${widget.category} Quiz'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ...List.generate(answers.length, (index) {
                final icon = getAnswerIcon(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getAnswerColor(index),
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => selectAnswer(index),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            answers[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (icon != null) Icon(icon),
                      ],
                    ),
                  ),
                );
              }),

              if (answered) ...[
                const SizedBox(height: 8),
                Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      currentQuestion.explanation,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ),
              ],

              Text(
                'Score: $score',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: answered ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1
                      ? 'Finish Quiz'
                      : 'Next Question',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
