import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/question_set.dart';
import '../repositories/daily_challenge_progress_repository.dart';
import '../repositories/daily_challenge_repository.dart';
import '../repositories/question_repository.dart';
import '../repositories/question_set_repository.dart';
import '../widgets/question_explanation_video_button.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String questionSetId;

  const QuizScreen({
    super.key,
    required this.questionSetId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionRepository _questionRepository = QuestionRepository();

  final QuestionSetRepository _questionSetRepository =
      QuestionSetRepository();

  final DailyChallengeRepository _dailyChallengeRepository =
      DailyChallengeRepository();

  final DailyChallengeProgressRepository
  _dailyChallengeProgressRepository =
      DailyChallengeProgressRepository();

  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;

  bool answered = false;
  bool isLoading = true;
  bool isFinishing = false;

  String? loadError;

  QuestionSet? questionSet;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    try {
      final loadedQuestionSet =
          await _questionSetRepository.getQuestionSetById(
            widget.questionSetId,
          );

      if (loadedQuestionSet == null) {
        throw Exception(
          'Question set not found: ${widget.questionSetId}',
        );
      }

      var loadedQuestions =
          await _questionRepository.getQuestionsByIds(
            loadedQuestionSet.questionIds,
            includePremium: true,
          );

      if (loadedQuestionSet.shuffleQuestions) {
        loadedQuestions.shuffle();
      }

      if (loadedQuestionSet.hasQuestionLimit &&
          loadedQuestions.length >
              loadedQuestionSet.maximumQuestions!) {
        loadedQuestions = loadedQuestions
            .take(loadedQuestionSet.maximumQuestions!)
            .toList();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        questionSet = loadedQuestionSet;
        questions = loadedQuestions;
        isLoading = false;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        questions = [];
        isLoading = false;
        loadError = error.toString();
      });
    }
  }

  String get _quizTitle {
    return questionSet?.title ?? 'Assessment';
  }

  bool get _isDailyChallenge {
    return questionSet?.assessmentType ==
        'daily_challenge';
  }

  void _selectAnswer(int index) {
    if (answered) {
      return;
    }

    final currentQuestion =
        questions[currentQuestionIndex];

    final selectedAnswer =
        currentQuestion.options[index];

    setState(() {
      selectedAnswerIndex = index;
      answered = true;

      if (selectedAnswer ==
          currentQuestion.correctAnswer) {
        score++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (currentQuestionIndex <
        questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        answered = false;
      });

      return;
    }

    await _finishAssessment();
  }

  Future<void> _finishAssessment() async {
    if (isFinishing) {
      return;
    }

    setState(() {
      isFinishing = true;
    });

    try {
      if (_isDailyChallenge) {
        final challenge =
            await _dailyChallengeRepository
                .getTodayChallenge();

        if (challenge != null) {
          await _dailyChallengeProgressRepository
              .saveCompletion(
                date: DateTime.now(),
                challengeId: challenge.id,
                questionSetId:
                    questionSet!.id,
                score: score,
                totalQuestions:
                    questions.length,
              );
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            totalQuestions: questions.length,
            category: _quizTitle,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isFinishing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to complete assessment. $error',
          ),
        ),
      );
    }
  }

  Color _answerColor(int index) {
    if (!answered) {
      return Colors.white;
    }

    final question =
        questions[currentQuestionIndex];

    final answer = question.options[index];

    if (answer == question.correctAnswer) {
      return Colors.green.shade100;
    }

    if (index == selectedAnswerIndex) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  IconData? _answerIcon(int index) {
    if (!answered) {
      return null;
    }

    final question =
        questions[currentQuestionIndex];

    final answer = question.options[index];

    if (answer == question.correctAnswer) {
      return Icons.check_circle_rounded;
    }

    if (index == selectedAnswerIndex) {
      return Icons.cancel_rounded;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Assessment'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load this assessment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loadError!,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_quizTitle),
        ),
        body: const Center(
          child: Text(
            'No questions were found for this assessment.',
          ),
        ),
      );
    }

    final currentQuestion =
        questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(_quizTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} '
                'of ${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value:
                    (currentQuestionIndex + 1) /
                    questions.length,
                minHeight: 8,
                borderRadius:
                    BorderRadius.circular(20),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ...List.generate(
                currentQuestion.options.length,
                (index) {
                  final icon =
                      _answerIcon(index);

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                                _answerColor(index),
                            foregroundColor:
                                Colors.black87,
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 14,
                                ),
                          ),
                      onPressed: () =>
                          _selectAnswer(index),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentQuestion
                                  .options[index],
                              style:
                                  const TextStyle(
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                          if (icon != null)
                            Icon(icon),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (answered) ...[
                const SizedBox(height: 8),

                if (currentQuestion
                    .hasExplanation)
                  Card(
                    color:
                        Colors.orange.shade50,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                            14,
                          ),
                      child: Text(
                        currentQuestion
                            .explanation,
                        style:
                            const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ),

                if (currentQuestion
                    .hasExplanationVideo) ...[
                  const SizedBox(height: 10),
                  QuestionExplanationVideoButton(
                    videoUrl:
                        currentQuestion
                            .explanationVideoUrl!,
                    videoTitle:
                        currentQuestion
                            .explanationVideoTitle,
                    videoProvider:
                        currentQuestion
                            .explanationVideoProvider,
                  ),
                ],
              ],

              const SizedBox(height: 14),

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
                onPressed:
                    answered && !isFinishing
                    ? _nextQuestion
                    : null,
                child: isFinishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                      )
                    : Text(
                        currentQuestionIndex ==
                                questions.length -
                                    1
                            ? 'Finish Quiz'
                            : 'Next Question',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}