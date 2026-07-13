import 'package:flutter/material.dart';

import '../models/programme.dart';
import '../repositories/programme_repository.dart';
import 'premium_screen.dart';
import 'subject_list_screen.dart';

class ProgrammeListScreen extends StatefulWidget {
  final String branchId;
  final String title;

  const ProgrammeListScreen({
    super.key,
    required this.branchId,
    required this.title,
  });

  @override
  State<ProgrammeListScreen> createState() => _ProgrammeListScreenState();
}

class _ProgrammeListScreenState extends State<ProgrammeListScreen> {
  final ProgrammeRepository _programmeRepository = ProgrammeRepository();

  late Future<List<Programme>> _programmesFuture;

  @override
  void initState() {
    super.initState();
    _programmesFuture = _programmeRepository.getProgrammesByBranch(
      widget.branchId,
    );
  }

  Future<void> _reloadProgrammes() async {
    final newFuture = _programmeRepository.getProgrammesByBranch(
      widget.branchId,
    );

    setState(() {
      _programmesFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openProgramme(Programme programme) async {
    if (programme.isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectListScreen(
          programmeId: programme.id,
          title: programme.title,
        ),
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
        onRefresh: _reloadProgrammes,
        child: FutureBuilder<List<Programme>>(
          future: _programmesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [_ProgrammeErrorCard(onRetry: _reloadProgrammes)],
              );
            }

            final programmes = snapshot.data ?? <Programme>[];

            if (programmes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [_EmptyProgrammeCard()],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _ProgrammeHeader(
                  branchTitle: widget.title,
                  programmeCount: programmes.length,
                ),
                const SizedBox(height: 18),
                ...programmes.map(
                  (programme) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProgrammeCard(
                      programme: programme,
                      onTap: () => _openProgramme(programme),
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

class _ProgrammeHeader extends StatelessWidget {
  final String branchTitle;
  final int programmeCount;

  const _ProgrammeHeader({
    required this.branchTitle,
    required this.programmeCount,
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
            'PROGRAMMES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            branchTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$programmeCount learning '
            '${programmeCount == 1 ? 'programme' : 'programmes'} available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgrammeCard extends StatelessWidget {
  final Programme programme;
  final VoidCallback onTap;

  const _ProgrammeCard({required this.programme, required this.onTap});

  IconData get icon {
    switch (programme.iconName) {
      case 'psychology':
        return Icons.psychology_alt_outlined;

      case 'school':
        return Icons.school_outlined;

      case 'language':
        return Icons.language_outlined;

      case 'government':
        return Icons.account_balance_outlined;

      case 'child':
        return Icons.child_friendly_outlined;

      case 'pets':
        return Icons.pets_outlined;

      default:
        return Icons.auto_stories_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final programmeColor = Color(programme.colorValue);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: programmeColor.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
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
                  color: programmeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  programme.isPremium ? Icons.lock_outline_rounded : icon,
                  size: 29,
                  color: programmeColor,
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
                            programme.title,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (programme.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      programme.description,
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
                          programme.isPremium
                              ? 'View programme'
                              : 'Explore subjects',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: programmeColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: programmeColor,
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

class _ProgrammeErrorCard extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ProgrammeErrorCard({required this.onRetry});

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
              'Unable to load programmes.',
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

class _EmptyProgrammeCard extends StatelessWidget {
  const _EmptyProgrammeCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No programmes are currently available.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
