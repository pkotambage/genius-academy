import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../repositories/lesson_progress_repository.dart';
import '../widgets/lesson_content_renderer.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LessonProgressRepository _progressRepository =
      LessonProgressRepository();

  bool _isLoadingProgress = true;
  bool _isSaving = false;
  bool _isCompleted = false;

  Lesson get lesson => widget.lesson;

  @override
  void initState() {
    super.initState();
    _loadAndStartProgress();
  }

  Future<void> _loadAndStartProgress() async {
    try {
      final progress = await _progressRepository.getProgress(lesson.id);

      if (!progress.isCompleted) {
        await _progressRepository.markLessonOpened(lesson.id);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isCompleted = progress.isCompleted;
        _isLoadingProgress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load lesson progress.')),
      );
    }
  }

  Future<void> _markCompleted() async {
    if (_isSaving || _isCompleted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _progressRepository.completeLesson(lesson.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _isCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson completed. Great work!')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save lesson progress.')),
      );
    }
  }

  void _startQuiz() {
    final questionSetId = lesson.questionSetId;

    if (questionSetId == null || questionSetId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No quiz is linked to this lesson yet.')),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(questionSetId: questionSetId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lesson',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      backgroundColor: cs.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _LessonHeader(lesson: lesson),

          const SizedBox(height: 20),

          if (lesson.learningObjectives.isNotEmpty) ...[
            Text(
              'What you will learn',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _LearningObjectivesCard(objectives: lesson.learningObjectives),
            const SizedBox(height: 24),
          ],

          LessonContentRenderer(blocks: lesson.contentBlocks),

          if (_isLoadingProgress)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _CompleteLessonCard(
              isCompleted: _isCompleted,
              isSaving: _isSaving,
              onComplete: _markCompleted,
            ),

          if (lesson.hasQuiz) ...[
            const SizedBox(height: 18),
            _QuizCallToAction(lessonTitle: lesson.title, onStart: _startQuiz),
          ],
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final Lesson lesson;

  const _LessonHeader({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: lesson.difficulty,
              ),
              _HeaderChip(
                icon: Icons.schedule_rounded,
                label: '${lesson.estimatedMinutes} min',
              ),
              if (lesson.hasVideo)
                const _HeaderChip(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Video',
                ),
              if (lesson.isPremium)
                const _HeaderChip(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Premium',
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (lesson.summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              lesson.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningObjectivesCard extends StatelessWidget {
  final List<String> objectives;

  const _LearningObjectivesCard({required this.objectives});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: objectives.map((objective) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    objective,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CompleteLessonCard extends StatelessWidget {
  final bool isCompleted;
  final bool isSaving;
  final VoidCallback onComplete;

  const _CompleteLessonCard({
    required this.isCompleted,
    required this.isSaving,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E9) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF2E7D32)
                  : cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.flag_outlined,
              color: isCompleted ? Colors.white : cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Lesson Completed' : 'Finish This Lesson',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? 'Your progress has been saved.'
                      : 'Mark this lesson as completed when you finish learning.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!isCompleted)
            FilledButton(
              onPressed: isSaving ? null : onComplete,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Complete'),
            ),
        ],
      ),
    );
  }
}

class _QuizCallToAction extends StatelessWidget {
  final String lessonTitle;
  final VoidCallback onStart;

  const _QuizCallToAction({required this.lessonTitle, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_outlined, color: Color(0xFFF57C00)),
              SizedBox(width: 8),
              Text(
                'Ready to practise?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Test your understanding of $lessonTitle with the linked quiz.',
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start Lesson Quiz',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
