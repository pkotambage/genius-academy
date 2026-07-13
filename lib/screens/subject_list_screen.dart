import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import 'premium_screen.dart';
import 'topic_list_screen.dart';

class SubjectListScreen extends StatefulWidget {
  final String programmeId;
  final String title;

  const SubjectListScreen({
    super.key,
    required this.programmeId,
    required this.title,
  });

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectRepository _subjectRepository = SubjectRepository();

  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _subjectRepository.getSubjectsByProgramme(
      widget.programmeId,
    );
  }

  Future<void> _reloadSubjects() async {
    final newFuture = _subjectRepository.getSubjectsByProgramme(
      widget.programmeId,
    );

    setState(() {
      _subjectsFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openSubject(Subject subject) async {
    if (subject.isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TopicListScreen(subjectId: subject.id, title: subject.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _reloadSubjects,
        child: FutureBuilder<List<Subject>>(
          future: _subjectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [_SubjectErrorCard(onRetry: _reloadSubjects)],
              );
            }

            final subjects = snapshot.data ?? <Subject>[];

            if (subjects.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [_EmptySubjectCard()],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _SubjectHeader(
                  programmeTitle: widget.title,
                  subjectCount: subjects.length,
                ),
                const SizedBox(height: 18),
                ...subjects.map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubjectCard(
                      subject: subject,
                      onTap: () => _openSubject(subject),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final String programmeTitle;
  final int subjectCount;

  const _SubjectHeader({
    required this.programmeTitle,
    required this.subjectCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUBJECTS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            programmeTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$subjectCount '
            '${subjectCount == 1 ? 'subject' : 'subjects'} available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const _SubjectCard({required this.subject, required this.onTap});

  IconData get icon {
    switch (subject.iconName) {
      case 'psychology':
        return Icons.psychology_alt_outlined;

      case 'calculate':
        return Icons.calculate_outlined;

      case 'patterns':
        return Icons.grid_view_rounded;

      case 'language':
        return Icons.language_outlined;

      case 'science':
        return Icons.science_outlined;

      case 'history':
        return Icons.history_edu_outlined;

      case 'menu_book':
        return Icons.menu_book_outlined;

      default:
        return Icons.auto_stories_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subjectColor = Color(subject.colorValue);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: subjectColor.withValues(alpha: 0.16)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  subject.isPremium ? Icons.lock_outline_rounded : icon,
                  size: 29,
                  color: subjectColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            subject.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (subject.isPremium) _PremiumBadge(color: cs.primary),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subject.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          subject.isPremium ? 'View subject' : 'Explore topics',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: subjectColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: subjectColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final Color color;

  const _PremiumBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Premium',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _SubjectErrorCard extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _SubjectErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 34, color: cs.onErrorContainer),
            const SizedBox(height: 10),
            Text(
              'Unable to load subjects.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class _EmptySubjectCard extends StatelessWidget {
  const _EmptySubjectCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No subjects are currently available.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
