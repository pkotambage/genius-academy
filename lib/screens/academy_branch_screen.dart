import 'package:flutter/material.dart';

import '../models/academy_branch.dart';
import '../models/daily_challenge_progress.dart';
import '../repositories/academy_branch_repository.dart';
import '../repositories/daily_challenge_progress_repository.dart';
import '../repositories/daily_challenge_repository.dart';
import 'iq_home_screen.dart';
import 'premium_screen.dart';
import 'programme_list_screen.dart';
import 'quiz_screen.dart';

class AcademyBranchScreen extends StatefulWidget {
  const AcademyBranchScreen({super.key});

  @override
  State<AcademyBranchScreen> createState() => _AcademyBranchScreenState();
}

class _AcademyBranchScreenState extends State<AcademyBranchScreen> {
  final AcademyBranchRepository _branchRepository =
      AcademyBranchRepository();

  final DailyChallengeRepository _dailyChallengeRepository =
      DailyChallengeRepository();

  final DailyChallengeProgressRepository
  _dailyChallengeProgressRepository =
      DailyChallengeProgressRepository();

  late Future<List<AcademyBranch>> _branchesFuture;

  DailyChallengeProgress? _todayProgress;

  int _streakCount = 0;

  bool _isOpeningDailyChallenge = false;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();

    _branchesFuture = _branchRepository.getBranches();

    _loadDailyChallengeProgress();
  }

  Future<void> _reloadBranches() async {
    setState(() {
      _branchesFuture = _branchRepository.getBranches();
    });

    await _branchesFuture;

    await _loadDailyChallengeProgress();
  }

  Future<void> _loadDailyChallengeProgress() async {
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

  void _openBranch(AcademyBranch branch) {
    if (branch.id == 'genius_iq') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProgrammeListScreen(
            branchId: 'genius_iq',
            title: 'Genius IQ',
          ),
        ),
      );
      return;
    }

    if (branch.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PremiumScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${branch.name} is coming soon.'),
      ),
    );
  }

  Future<void> _openDailyChallenge() async {
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

      await _loadDailyChallengeProgress();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load today\'s Daily Challenge. $error',
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

  void _openGeniusIq() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IqHomeScreen(),
      ),
    );
  }

  void _openPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PremiumScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Genius Academy',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Premium',
            onPressed: _openPremium,
            icon: const Icon(
              Icons.workspace_premium_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadBranches,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            28,
          ),
          children: [
            _WelcomeBanner(
              onStart: _openDailyChallenge,
              isLoading: _isOpeningDailyChallenge,
              progress: _todayProgress,
            ),

            const SizedBox(height: 24),

            _SectionHeader(
              title: 'Explore Genius Academy',
              subtitle:
                  'Choose the learning path that matches your goals.',
              actionLabel: 'Premium',
              onAction: _openPremium,
            ),

            const SizedBox(height: 14),

            FutureBuilder<List<AcademyBranch>>(
              future: _branchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 56,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _BranchErrorCard(
                    onRetry: _reloadBranches,
                  );
                }

                final branches =
                    snapshot.data ?? <AcademyBranch>[];

                if (branches.isEmpty) {
                  return const _EmptyBranchCard();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide =
                        constraints.maxWidth >= 760;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: branches.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                isWide ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                isWide ? 0.98 : 0.86,
                          ),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final branch =
                            branches[index];

                        return _AcademyBranchCard(
                          branch: branch,
                          onTap: () =>
                              _openBranch(branch),
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            const _SectionHeader(
              title: 'Your Learning Journey',
              subtitle:
                  'Build consistency and keep improving every day.',
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _ProgressCard(
                    icon: Icons
                        .local_fire_department_outlined,
                    title: _isLoadingProgress
                        ? '...'
                        : '$_streakCount Days',
                    subtitle: 'Current streak',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _ProgressCard(
                    icon:
                        Icons.check_circle_outline_rounded,
                    title: _isLoadingProgress
                        ? '...'
                        : _todayProgress == null
                        ? 'Not Yet'
                        : '${_todayProgress!.score}/${_todayProgress!.totalQuestions}',
                    subtitle:
                        _todayProgress == null
                        ? 'Today\'s challenge'
                        : 'Today completed',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _ContinueLearningCard(
              onTap: _openGeniusIq,
            ),

            const SizedBox(height: 24),

            _PremiumBanner(
              onTap: _openPremium,
            ),
          ],
        ),
      ),
      backgroundColor: cs.surface,
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final Future<void> Function() onStart;
  final bool isLoading;
  final DailyChallengeProgress? progress;

  const _WelcomeBanner({
    required this.onStart,
    required this.isLoading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isCompleted = progress != null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withValues(
              alpha: 0.78,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(
              alpha: 0.22,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted
                  ? '✓ DAILY CHALLENGE COMPLETED'
                  : 'LEARN • GROW • SUCCEED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isCompleted
                ? 'Great work today!'
                : 'Welcome to\nGenius Academy',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            isCompleted
                ? 'You scored ${progress!.score} out of '
                      '${progress!.totalQuestions}. '
                      'Come back tomorrow and keep your streak growing.'
                : 'A complete learning platform for aptitude, '
                      'education, languages, examinations and '
                      'life skills.',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.9,
              ),
              fontSize: 14,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor:
                  Colors.white,
              foregroundColor:
                  cs.primary,
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
              shape:
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                  ),
            ),
            onPressed:
                isLoading ? null : onStart,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                  )
                : Icon(
                    isCompleted
                        ? Icons.replay_rounded
                        : Icons
                              .play_arrow_rounded,
                  ),
            label: Text(
              isLoading
                  ? 'Loading Challenge...'
                  : isCompleted
                  ? 'Play Again'
                  : 'Start Daily Challenge',
              style: const TextStyle(
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color:
                      cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        if (actionLabel != null &&
            onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
            ),
          ),
      ],
    );
  }
}

class _AcademyBranchCard
    extends StatelessWidget {
  final AcademyBranch branch;
  final VoidCallback onTap;

  const _AcademyBranchCard({
    required this.branch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    final isAvailable =
        branch.id == 'genius_iq';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(22),
        side: BorderSide(
          color: branch.color.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(16),
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
                    decoration:
                        BoxDecoration(
                          color: branch.color
                              .withValues(
                                alpha:
                                    0.13,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                17,
                              ),
                        ),
                    child: Icon(
                      branch.icon,
                      size: 28,
                      color:
                          branch.color,
                    ),
                  ),

                  const Spacer(),

                  _StatusBadge(
                    isAvailable:
                        isAvailable,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                branch.name,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight:
                      FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Text(
                  branch.description,
                  maxLines: 4,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color:
                        cs.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Text(
                    isAvailable
                        ? 'Start learning'
                        : 'View path',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          branch.color,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 18,
                    color:
                        branch.color,
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

class _StatusBadge
    extends StatelessWidget {
  final bool isAvailable;

  const _StatusBadge({
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
      decoration: BoxDecoration(
        color: isAvailable
            ? const Color(0xFFE8F5E9)
            : cs.primary.withValues(
                alpha: 0.1,
              ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            isAvailable
                ? Icons
                      .check_circle_outline
                : Icons.lock_outline,
            size: 13,
            color: isAvailable
                ? const Color(
                    0xFF2E7D32,
                  )
                : cs.primary,
          ),

          const SizedBox(width: 4),

          Text(
            isAvailable
                ? 'Open'
                : 'Premium',
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              color: isAvailable
                  ? const Color(
                      0xFF2E7D32,
                    )
                  : cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            cs.surfaceContainerHigh,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
                  color: cs.primary
                      .withValues(
                        alpha: 0.1,
                      ),
                  borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                ),
            child: Icon(
              icon,
              color: cs.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard
    extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueLearningCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                      color:
                          const Color(
                            0xFFFFF3E0,
                          ),
                      borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                    ),
                child: const Icon(
                  Icons
                      .psychology_alt_outlined,
                  color:
                      Color(0xFFF57C00),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Continue with Genius IQ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            cs.onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Logic, mathematics, patterns and aptitude.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: cs
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBanner
    extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumBanner({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF3E0),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .workspace_premium_rounded,
            size: 36,
            color: Color(
              0xFFF57C00,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock the Complete Academy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Access premium learning paths, lessons and quizzes.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          FilledButton(
            style:
                FilledButton.styleFrom(
                  backgroundColor:
                      const Color(
                        0xFFF57C00,
                      ),
                ),
            onPressed: onTap,
            child:
                const Text('View'),
          ),
        ],
      ),
    );
  }
}

class _BranchErrorCard
    extends StatelessWidget {
  final Future<void> Function()
  onRetry;

  const _BranchErrorCard({
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
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 34,
              color:
                  cs.onErrorContainer,
            ),

            const SizedBox(height: 10),

            Text(
              'Unable to load learning paths.',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
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

class _EmptyBranchCard
    extends StatelessWidget {
  const _EmptyBranchCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding:
            EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No learning paths are currently available.',
          ),
        ),
      ),
    );
  }
}