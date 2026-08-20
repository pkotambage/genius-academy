import 'package:flutter/material.dart';

import '../models/daily_challenge_progress.dart';
import '../repositories/daily_challenge_progress_repository.dart';
import '../repositories/daily_challenge_repository.dart';
import 'programme_list_screen.dart';
import 'quiz_screen.dart';

class IqHomeScreen extends StatefulWidget {
  const IqHomeScreen({super.key});

  @override
  State<IqHomeScreen> createState() => _IqHomeScreenState();
}

class _IqHomeScreenState extends State<IqHomeScreen> {
  final DailyChallengeRepository _dailyChallengeRepository =
      DailyChallengeRepository();

  final DailyChallengeProgressRepository _dailyChallengeProgressRepository =
      DailyChallengeProgressRepository();

  DailyChallengeProgress? _todayProgress;

  int _streakCount = 0;

  bool _isLoadingProgress = true;
  bool _isOpeningDailyChallenge = false;

  @override
  void initState() {
    super.initState();
    _loadDailyProgress();
  }

  Future<void> _loadDailyProgress() async {
    final todayProgress =
        await _dailyChallengeProgressRepository.getTodayProgress();

    final streak =
        await _dailyChallengeProgressRepository.getCurrentStreak();

    if (!mounted) {
      return;
    }

    setState(() {
      _todayProgress = todayProgress;
      _streakCount = streak;
      _isLoadingProgress = false;
    });
  }

  Future<void> _startDailyChallenge() async {
    if (_isOpeningDailyChallenge) {
      return;
    }

    setState(() {
      _isOpeningDailyChallenge = true;
    });

    try {
      final challenge =
          await _dailyChallengeRepository.getTodayChallenge();

      if (!mounted) {
        return;
      }

      if (challenge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Today\'s Daily Challenge is not available yet.',
            ),
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            questionSetId: challenge.questionSetId,
          ),
        ),
      );

      await _loadDailyProgress();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load today\'s Daily Challenge.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningDailyChallenge = false;
        });
      }
    }
  }

  void _openLearningPath() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgrammeListScreen(
          branchId: 'genius_iq',
          title: 'Genius IQ',
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await _loadDailyProgress();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Genius IQ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            28,
          ),
          children: [
            const Text(
              'Train Your Mind',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Build stronger reasoning skills through daily practice '
              'and structured learning.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: cs.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 22),

            _DailyChallengeCard(
              progress: _todayProgress,
              isLoading: _isOpeningDailyChallenge,
              onStart: _startDailyChallenge,
            ),

            const SizedBox(height: 24),

            const _SectionTitle(
              title: 'Your Progress',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    title: _isLoadingProgress
                        ? '...'
                        : '$_streakCount',
                    subtitle: _streakCount == 1
                        ? 'Day streak'
                        : 'Day streak',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    title: _isLoadingProgress
                        ? '...'
                        : _todayProgress == null
                            ? 'Not yet'
                            : '${_todayProgress!.score}/${_todayProgress!.totalQuestions}',
                    subtitle: _todayProgress == null
                        ? 'Today\'s challenge'
                        : 'Today completed',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            const _SectionTitle(
              title: 'Structured Learning',
            ),

            const SizedBox(height: 12),

            _LearningPathCard(
              onTap: _openLearningPath,
            ),

            const SizedBox(height: 22),

            _ConsistencyCard(
              streakCount: _streakCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final DailyChallengeProgress? progress;
  final bool isLoading;
  final Future<void> Function() onStart;

  const _DailyChallengeCard({
    required this.progress,
    required this.isLoading,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isCompleted = progress != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.bolt_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY CHALLENGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isCompleted
                          ? 'Completed Today'
                          : '10 Questions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            isCompleted
                ? 'Great work. Your best score today is '
                    '${progress!.score}/${progress!.totalQuestions}.'
                : 'A quick daily reasoning workout with instant '
                    'answers and explanations.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.45,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          FilledButton.icon(
            onPressed: isLoading ? null : onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isCompleted
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                  ),
            label: Text(
              isLoading
                  ? 'Loading...'
                  : isCompleted
                      ? 'Play Again'
                      : 'Start Challenge',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: cs.primary,
            size: 28,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LearningPathCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.psychology_alt_outlined,
                  color: cs.primary,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Logical Reasoning',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Learn concepts step by step and test your '
                      'understanding with lesson quizzes.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  final int streakCount;

  const _ConsistencyCard({
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final progress = (streakCount.clamp(0, 7)) / 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                '7-Day Consistency Goal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            '$streakCount of 7 consecutive days',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}