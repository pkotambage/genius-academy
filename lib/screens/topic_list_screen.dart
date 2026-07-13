import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../repositories/topic_repository.dart';
import 'lesson_list_screen.dart';
import 'premium_screen.dart';

class TopicListScreen extends StatefulWidget {
  final String subjectId;
  final String title;

  const TopicListScreen({
    super.key,
    required this.subjectId,
    required this.title,
  });

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  final TopicRepository _topicRepository = TopicRepository();

  late Future<List<Topic>> _topicsFuture;

  @override
  void initState() {
    super.initState();

    _topicsFuture = _topicRepository.getTopicsBySubject(widget.subjectId);
  }

  Future<void> _reloadTopics() async {
    final newFuture = _topicRepository.getTopicsBySubject(widget.subjectId);

    setState(() {
      _topicsFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openTopic(Topic topic) async {
    if (topic.isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonListScreen(topicId: topic.id, title: topic.title),
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
        onRefresh: _reloadTopics,
        child: FutureBuilder<List<Topic>>(
          future: _topicsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [_TopicErrorCard(onRetry: _reloadTopics)],
              );
            }

            final topics = snapshot.data ?? <Topic>[];

            if (topics.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [_EmptyTopicCard()],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _TopicHeader(
                  subjectTitle: widget.title,
                  topicCount: topics.length,
                ),
                const SizedBox(height: 18),
                ...topics.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TopicCard(
                      topic: topic,
                      onTap: () => _openTopic(topic),
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

class _TopicHeader extends StatelessWidget {
  final String subjectTitle;
  final int topicCount;

  const _TopicHeader({required this.subjectTitle, required this.topicCount});

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
            'TOPICS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subjectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$topicCount '
            '${topicCount == 1 ? 'topic' : 'topics'} available',
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

class _TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  IconData get icon {
    switch (topic.iconName) {
      case 'lightbulb':
        return Icons.lightbulb_outline_rounded;

      case 'psychology':
        return Icons.psychology_alt_outlined;

      case 'calculate':
        return Icons.calculate_outlined;

      case 'patterns':
        return Icons.grid_view_rounded;

      case 'language':
        return Icons.language_outlined;

      case 'quiz':
        return Icons.quiz_outlined;

      default:
        return Icons.topic_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topicColor = Color(topic.colorValue);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: topicColor.withValues(alpha: 0.16)),
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
                  color: topicColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  topic.isPremium ? Icons.lock_outline_rounded : icon,
                  size: 29,
                  color: topicColor,
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
                            topic.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (topic.isPremium)
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
                      topic.description,
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
                          topic.isPremium ? 'View topic' : 'Explore lessons',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: topicColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: topicColor,
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

class _TopicErrorCard extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _TopicErrorCard({required this.onRetry});

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
              'Unable to load topics.',
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

class _EmptyTopicCard extends StatelessWidget {
  const _EmptyTopicCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No topics are currently available.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
