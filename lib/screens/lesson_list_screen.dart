import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/lesson_progress.dart';
import '../models/question_set.dart';
import '../repositories/lesson_progress_repository.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/question_set_repository.dart';
import '../widgets/course_progress_card.dart';
import 'lesson_screen.dart';
import 'premium_screen.dart';
import 'quiz_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String topicId;
  final String title;

  const LessonListScreen({
    super.key,
    required this.topicId,
    required this.title,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonRepository _lessonRepository = LessonRepository();

  final LessonProgressRepository _progressRepository =
      LessonProgressRepository();

  final QuestionSetRepository _questionSetRepository =
      QuestionSetRepository();

  late Future<_LessonListData> _screenDataFuture;

  @override
  void initState() {
    super.initState();
    _screenDataFuture = _loadScreenData();
  }

  Future<_LessonListData> _loadScreenData() async {
    final results = await Future.wait([
      _lessonRepository.getLessonsByTopic(widget.topicId),
      _progressRepository.getAllProgress(),
      _questionSetRepository.getQuestionSetsByTopic(widget.topicId),
    ]);

    final lessons = results[0] as List<Lesson>;
    final progressMap = results[1] as Map<String, LessonProgress>;
    final questionSets = results[2] as List<QuestionSet>;

    QuestionSet? topicQuiz;

    for (final questionSet in questionSets) {
      if (questionSet.assessmentType.trim().toLowerCase() == 'topic_quiz') {
        topicQuiz = questionSet;
        break;
      }
    }

    return _LessonListData(
      lessons: lessons,
      progressMap: progressMap,
      topicQuiz: topicQuiz,
    );
  }

  Future<void> _reloadScreen() async {
    final newFuture = _loadScreenData();

    setState(() {
      _screenDataFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openLesson(Lesson lesson) async {
    if (lesson.isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
    );

    if (!mounted) {
      return;
    }

    await _reloadScreen();
  }

  Future<void> _continueLearning(_LessonListData data) async {
    final lesson = data.continueLesson;

    if (lesson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All available lessons are completed.'),
        ),
      );

      return;
    }

    await _openLesson(lesson);
  }

  Future<void> _openTopicQuiz(_LessonListData data) async {
    final topicQuiz = data.topicQuiz;

    if (topicQuiz == null) {
      return;
    }

    if (!data.allLessonsCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete all lessons to unlock the Topic Quiz.',
          ),
        ),
      );

      return;
    }

    if (topicQuiz.isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questionSetId: topicQuiz.id,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _reloadScreen();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _reloadScreen,
        child: FutureBuilder<_LessonListData>(
          future: _screenDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _LessonErrorCard(
                    onRetry: _reloadScreen,
                  ),
                ],
              );
            }

            final data = snapshot.data;

            if (data == null || data.lessons.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  _EmptyLessonCard(),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                28,
              ),
              children: [
                CourseProgressCard(
                  title: widget.title,
                  completedLessons: data.completedLessonCount,
                  totalLessons: data.lessons.length,
                  onContinue: data.continueLesson == null
                      ? null
                      : () => _continueLearning(data),
                ),
                const SizedBox(height: 24),
                _LessonSectionHeader(
                  totalLessons: data.lessons.length,
                  completedLessons: data.completedLessonCount,
                ),
                const SizedBox(height: 14),
                ...data.lessons.map((lesson) {
                  final progress =
                      data.progressForLesson(lesson.id);

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _LessonCard(
                      lesson: lesson,
                      progress: progress,
                      isContinueLesson:
                          data.continueLesson?.id == lesson.id,
                      onTap: () => _openLesson(lesson),
                    ),
                  );
                }),
                if (data.topicQuiz != null) ...[
                  const SizedBox(height: 16),
                  _TopicQuizSectionHeader(
                    isUnlocked: data.allLessonsCompleted,
                  ),
                  const SizedBox(height: 14),
                  _TopicQuizCard(
                    questionSet: data.topicQuiz!,
                    isUnlocked: data.allLessonsCompleted,
                    onTap: () => _openTopicQuiz(data),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonListData {
  final List<Lesson> lessons;
  final Map<String, LessonProgress> progressMap;
  final QuestionSet? topicQuiz;

  const _LessonListData({
    required this.lessons,
    required this.progressMap,
    required this.topicQuiz,
  });

  LessonProgress progressForLesson(String lessonId) {
    return progressMap[lessonId] ??
        LessonProgress.notStarted(
          lessonId: lessonId,
        );
  }

  int get completedLessonCount {
    return lessons.where((lesson) {
      return progressForLesson(
        lesson.id,
      ).isCompleted;
    }).length;
  }

  bool get allLessonsCompleted {
    return lessons.isNotEmpty &&
        completedLessonCount == lessons.length;
  }

  Lesson? get continueLesson {
    for (final lesson in lessons) {
      final progress =
          progressForLesson(lesson.id);

      if (progress.status ==
          LessonProgressStatus.inProgress) {
        return lesson;
      }
    }

    for (final lesson in lessons) {
      final progress =
          progressForLesson(lesson.id);

      if (progress.status ==
          LessonProgressStatus.notStarted) {
        return lesson;
      }
    }

    return null;
  }
}

class _LessonSectionHeader extends StatelessWidget {
  final int totalLessons;
  final int completedLessons;

  const _LessonSectionHeader({
    required this.totalLessons,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Lessons',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedLessons completed • '
                '$totalLessons total',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: cs.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            '$completedLessons / $totalLessons',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicQuizSectionHeader
    extends StatelessWidget {
  final bool isUnlocked;

  const _TopicQuizSectionHeader({
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Topic Assessment',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isUnlocked
                    ? 'Your final assessment is ready.'
                    : 'Complete all lessons to unlock.',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicQuizCard extends StatelessWidget {
  final QuestionSet questionSet;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _TopicQuizCard({
    required this.questionSet,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final iconColor = isUnlocked
        ? cs.primary
        : cs.onSurfaceVariant;

    final iconBackground = isUnlocked
        ? cs.primary.withValues(alpha: 0.12)
        : cs.surfaceContainerHighest;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isUnlocked
              ? cs.primary.withValues(alpha: 0.45)
              : cs.outlineVariant.withValues(alpha: 0.45),
          width: isUnlocked ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                    child: Icon(
                      isUnlocked
                          ? Icons.emoji_events_outlined
                          : Icons.lock_outline_rounded,
                      color: iconColor,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                questionSet.title,
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.25,
                                  fontWeight:
                                      FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isUnlocked
                                    ? cs.primary
                                        .withValues(
                                            alpha: 0.1)
                                    : cs
                                        .surfaceContainerHighest,
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUnlocked
                                        ? Icons
                                            .check_circle_outline_rounded
                                        : Icons
                                            .lock_outline_rounded,
                                    size: 13,
                                    color: isUnlocked
                                        ? cs.primary
                                        : cs
                                            .onSurfaceVariant,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    isUnlocked
                                        ? 'Ready'
                                        : 'Locked',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: isUnlocked
                                          ? cs.primary
                                          : cs
                                              .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          questionSet.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color:
                                cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _LessonMeta(
                    icon:
                        Icons.quiz_outlined,
                    label:
                        '${questionSet.questionIds.length} questions',
                  ),
                  _LessonMeta(
                    icon:
                        Icons.flag_outlined,
                    label:
                        '${questionSet.passPercentage.toStringAsFixed(0)}% pass',
                  ),
                  const _LessonMeta(
                    icon:
                        Icons.replay_rounded,
                    label: 'Retake allowed',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      isUnlocked ? onTap : null,
                  icon: Icon(
                    isUnlocked
                        ? Icons.play_arrow_rounded
                        : Icons.lock_outline_rounded,
                  ),
                  label: Text(
                    isUnlocked
                        ? 'Start Topic Quiz'
                        : 'Complete All Lessons',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final LessonProgress progress;
  final bool isContinueLesson;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.progress,
    required this.isContinueLesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final statusStyle =
        _LessonStatusStyle.fromProgress(
      progress,
      cs,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isContinueLesson
              ? cs.primary.withValues(
                  alpha: 0.45,
                )
              : cs.outlineVariant.withValues(
                  alpha: 0.45,
                ),
          width: isContinueLesson ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          statusStyle.iconBackground,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Icon(
                      lesson.isPremium
                          ? Icons
                              .lock_outline_rounded
                          : statusStyle.icon,
                      color:
                          statusStyle.iconColor,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.25,
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      cs.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _LessonStatusBadge(
                              label:
                                  lesson.isPremium
                                      ? 'Premium'
                                      : statusStyle
                                          .label,
                              backgroundColor:
                                  lesson.isPremium
                                      ? cs.primary
                                          .withValues(
                                              alpha:
                                                  0.1)
                                      : statusStyle
                                          .badgeBackground,
                              foregroundColor:
                                  lesson.isPremium
                                      ? cs.primary
                                      : statusStyle
                                          .badgeForeground,
                              icon:
                                  lesson.isPremium
                                      ? Icons
                                          .lock_outline
                                      : statusStyle
                                          .icon,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lesson.summary,
                          maxLines: 3,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color:
                                cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _LessonProgressBar(
                percentage:
                    progress.progressPercentage,
                statusStyle: statusStyle,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _LessonMeta(
                          icon: Icons
                              .schedule_outlined,
                          label:
                              '${lesson.estimatedMinutes} min',
                        ),
                        _LessonMeta(
                          icon: Icons
                              .signal_cellular_alt_rounded,
                          label:
                              lesson.difficulty,
                        ),
                        if (lesson.hasQuiz)
                          const _LessonMeta(
                            icon: Icons
                                .quiz_outlined,
                            label:
                                'Quiz included',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isContinueLesson &&
                      !progress.isCompleted)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .play_arrow_rounded,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            progress.isStarted
                                ? 'Continue'
                                : 'Start',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      Icons
                          .chevron_right_rounded,
                      color:
                          cs.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonProgressBar
    extends StatelessWidget {
  final int percentage;
  final _LessonStatusStyle statusStyle;

  const _LessonProgressBar({
    required this.percentage,
    required this.statusStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final normalizedProgress =
        percentage.clamp(0, 100) / 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                statusStyle.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      FontWeight.w700,
                  color: statusStyle
                      .badgeForeground,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight:
                    FontWeight.w800,
                color:
                    cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: 8,
            backgroundColor:
                cs.surfaceContainerHighest,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              statusStyle.progressColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonStatusBadge
    extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _LessonStatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LessonMeta({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LessonStatusStyle {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color progressColor;

  const _LessonStatusStyle({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.progressColor,
  });

  factory _LessonStatusStyle.fromProgress(
    LessonProgress progress,
    ColorScheme cs,
  ) {
    switch (progress.status) {
      case LessonProgressStatus.completed:
        return const _LessonStatusStyle(
          label: 'Completed',
          icon:
              Icons.check_circle_outline_rounded,
          iconColor: Color(0xFF2E7D32),
          iconBackground:
              Color(0xFFE8F5E9),
          badgeBackground:
              Color(0xFFE8F5E9),
          badgeForeground:
              Color(0xFF2E7D32),
          progressColor:
              Color(0xFF2E7D32),
        );

      case LessonProgressStatus.inProgress:
        return const _LessonStatusStyle(
          label: 'In Progress',
          icon:
              Icons.play_circle_outline_rounded,
          iconColor: Color(0xFFF57C00),
          iconBackground:
              Color(0xFFFFF3E0),
          badgeBackground:
              Color(0xFFFFF3E0),
          badgeForeground:
              Color(0xFFF57C00),
          progressColor:
              Color(0xFFF57C00),
        );

      case LessonProgressStatus.notStarted:
        return _LessonStatusStyle(
          label: 'Not Started',
          icon:
              Icons.menu_book_outlined,
          iconColor: cs.primary,
          iconBackground:
              cs.primary.withValues(
            alpha: 0.1,
          ),
          badgeBackground:
              cs.surfaceContainerHighest,
          badgeForeground:
              cs.onSurfaceVariant,
          progressColor:
              cs.primary.withValues(
            alpha: 0.45,
          ),
        );
    }
  }
}

class _LessonErrorCard
    extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _LessonErrorCard({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 34,
              color: cs.onErrorContainer,
            ),
            const SizedBox(height: 10),
            Text(
              'Unable to load lessons.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color:
                    cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onRetry,
              child:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLessonCard
    extends StatelessWidget {
  const _EmptyLessonCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No lessons are currently available.',
            textAlign:
                TextAlign.center,
          ),
        ),
      ),
    );
  }
}