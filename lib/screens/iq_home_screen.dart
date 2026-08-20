import 'package:flutter/material.dart';

import '../models/daily_challenge_progress.dart';
import '../models/quiz_category.dart';
import '../repositories/category_repository.dart';
import '../repositories/daily_challenge_progress_repository.dart';
import '../repositories/daily_challenge_repository.dart';
import 'premium_screen.dart';
import 'quiz_screen.dart';

class IqHomeScreen extends StatefulWidget {
  const IqHomeScreen({super.key});

  @override
  State<IqHomeScreen> createState() =>
      _IqHomeScreenState();
}

class _IqHomeScreenState
    extends State<IqHomeScreen> {
  final CategoryRepository
  _categoryRepository =
      CategoryRepository();

  final DailyChallengeRepository
  _dailyChallengeRepository =
      DailyChallengeRepository();

  final DailyChallengeProgressRepository
  _dailyChallengeProgressRepository =
      DailyChallengeProgressRepository();

  late Future<List<QuizCategory>>
  _categoriesFuture;

  DailyChallengeProgress?
  _todayProgress;

  int _streakCount = 0;

  bool _isOpeningDailyChallenge =
      false;

  @override
  void initState() {
    super.initState();

    _categoriesFuture =
        _categoryRepository
            .getCategories();

    _loadDailyProgress();
  }

  void _goToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PremiumScreen(),
      ),
    );
  }

  Future<void>
  _loadDailyProgress() async {
    final todayProgress =
        await _dailyChallengeProgressRepository
            .getTodayProgress();

    final streak =
        await _dailyChallengeProgressRepository
            .getCurrentStreak();

    if (!mounted) {
      return;
    }

    setState(() {
      _todayProgress =
          todayProgress;
      _streakCount = streak;
    });
  }

  Future<void>
  _startDailyChallenge() async {
    if (_isOpeningDailyChallenge) {
      return;
    }

    setState(() {
      _isOpeningDailyChallenge =
          true;
    });

    try {
      final challenge =
          await _dailyChallengeRepository
              .getTodayChallenge();

      if (!mounted) {
        return;
      }

      if (challenge == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
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
          builder: (_) =>
              QuizScreen(
                questionSetId:
                    challenge
                        .questionSetId,
              ),
        ),
      );

      await _loadDailyProgress();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load today\'s Daily Challenge. $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningDailyChallenge =
              false;
        });
      }
    }
  }

  void _openCategory(
    QuizCategory category,
  ) {
    if (category.isPremium) {
      _goToPremium();
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '${category.name} assessment is being migrated '
          'to the new Question Set engine.',
        ),
      ),
    );
  }

  Future<void>
  _reloadCategories() async {
    setState(() {
      _categoriesFuture =
          _categoryRepository
              .getCategories();
    });

    await _categoriesFuture;

    await _loadDailyProgress();
  }

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        title:
            const Text('Genius IQ'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon:
                  const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer();
              },
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reloadCategories,
        child: Container(
          color: cs.surface,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  16,
                ),
            children: [
              Text(
                'Welcome to Genius IQ!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              _ChallengeCard(
                onStart:
                    _startDailyChallenge,
                isLoading:
                    _isOpeningDailyChallenge,
                progress:
                    _todayProgress,
              ),

              const SizedBox(height: 20),

              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              FutureBuilder<
                List<QuizCategory>
              >(
                future:
                    _categoriesFuture,
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(
                            vertical: 32,
                          ),
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _CategoryErrorCard(
                      onRetry:
                          _reloadCategories,
                    );
                  }

                  final categories =
                      snapshot.data ??
                      <QuizCategory>[];

                  if (categories.isEmpty) {
                    return const _EmptyCategoryCard();
                  }

                  return GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              2.15,
                        ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final category =
                          categories[index];

                      return _CategoryPill(
                        label:
                            category.name,
                        icon:
                            category.icon,
                        color:
                            category.color,
                        locked:
                            category
                                .isPremium,
                        onTap: () =>
                            _openCategory(
                              category,
                            ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Your Streak ($_streakCount days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                child:
                    LinearProgressIndicator(
                      value:
                          (_streakCount
                                  .clamp(
                                    0,
                                    7,
                                  )) /
                              7,
                      minHeight: 14,
                      backgroundColor: cs
                          .surfaceContainerHighest,
                    ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(
                        backgroundColor:
                            const Color(
                              0xFFF57C00,
                            ),
                        padding:
                            const EdgeInsets.symmetric(
                              vertical:
                                  16,
                            ),
                        shape:
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                            ),
                      ),
                  onPressed:
                      _goToPremium,
                  child: const Text(
                    'Premium Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 56,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  color:
                      Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                ),
                child: const Text(
                  'Ad Banner Placeholder',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeCard
    extends StatelessWidget {
  final Future<void> Function()
  onStart;
  final bool isLoading;
  final DailyChallengeProgress?
  progress;

  const _ChallengeCard({
    required this.onStart,
    required this.isLoading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    final isCompleted =
        progress != null;

    return Card(
      color:
          cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Today\'s Challenge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color:
                                cs.onSurface,
                          ),
                        ),
                      ),

                      if (isCompleted) ...[
                        const SizedBox(
                          width: 7,
                        ),
                        const Icon(
                          Icons
                              .check_circle_rounded,
                          size: 20,
                          color: Color(
                            0xFF2E7D32,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isCompleted
                        ? 'Completed • Score '
                              '${progress!.score}/${progress!.totalQuestions}'
                        : 'Complete 10 questions and sharpen '
                              'your reasoning skills.',
                    style: TextStyle(
                      color: cs
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            FilledButton(
              style:
                  FilledButton.styleFrom(
                    backgroundColor:
                        const Color(
                          0xFFF57C00,
                        ),
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical: 12,
                        ),
                    shape:
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                        ),
                  ),
              onPressed:
                  isLoading
                  ? null
                  : onStart,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                    )
                  : Text(
                      isCompleted
                          ? 'Again'
                          : 'Start Quiz',
                      style:
                          const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool locked;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color:
              cs.surfaceContainerHigh,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 26,
                    color: color,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (locked)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                  decoration:
                      BoxDecoration(
                        color:
                            cs.primary,
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                      ),
                  child: const Icon(
                    Icons.lock,
                    size: 13,
                    color:
                        Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryErrorCard
    extends StatelessWidget {
  final Future<void> Function()
  onRetry;

  const _CategoryErrorCard({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Card(
      color: cs.errorContainer,
      elevation: 0,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color:
                  cs.onErrorContainer,
            ),

            const SizedBox(height: 8),

            Text(
              'Unable to load categories.',
              style: TextStyle(
                fontWeight:
                    FontWeight.w700,
                color:
                    cs.onErrorContainer,
              ),
            ),

            const SizedBox(height: 8),

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

class _EmptyCategoryCard
    extends StatelessWidget {
  const _EmptyCategoryCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding:
            EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No categories are currently available.',
          ),
        ),
      ),
    );
  }
}

class _AppDrawer
    extends StatelessWidget {
  const _AppDrawer();

  void _goToPremium(
    BuildContext context,
  ) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PremiumScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration:
                  BoxDecoration(
                    color: cs
                        .primaryContainer,
                  ),
              child: Align(
                alignment:
                    Alignment.bottomLeft,
                child: Text(
                  'Genius Academy\nTrain Your Mind',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    color: cs
                        .onPrimaryContainer,
                  ),
                ),
              ),
            ),

            ListTile(
              leading:
                  const Icon(
                    Icons.home_outlined,
                  ),
              title:
                  const Text('Home'),
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
            ),

            ListTile(
              leading:
                  const Icon(
                    Icons.person_outline,
                  ),
              title:
                  const Text('Profile'),
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
            ),

            ListTile(
              leading:
                  const Icon(
                    Icons
                        .workspace_premium_outlined,
                  ),
              title: const Text(
                'Premium Features',
              ),
              onTap: () {
                _goToPremium(
                  context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}