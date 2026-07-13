import 'package:flutter/material.dart';

import '../models/lesson.dart';

class LessonContentRenderer extends StatelessWidget {
  final List<LessonContentBlock> blocks;

  const LessonContentRenderer({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildBlock(context, block),
        );
      }).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, LessonContentBlock block) {
    switch (block.type) {
      case LessonContentType.heading:
        return _HeadingBlock(block: block);

      case LessonContentType.paragraph:
        return _ParagraphBlock(block: block);

      case LessonContentType.keyPoint:
        return _HighlightedBlock(
          block: block,
          icon: Icons.lightbulb_outline_rounded,
          backgroundColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1565C0),
        );

      case LessonContentType.example:
        return _HighlightedBlock(
          block: block,
          icon: Icons.menu_book_outlined,
          backgroundColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
        );

      case LessonContentType.tip:
        return _HighlightedBlock(
          block: block,
          icon: Icons.tips_and_updates_outlined,
          backgroundColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
        );

      case LessonContentType.important:
        return _HighlightedBlock(
          block: block,
          icon: Icons.priority_high_rounded,
          backgroundColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF7B1FA2),
        );

      case LessonContentType.warning:
        return _HighlightedBlock(
          block: block,
          icon: Icons.warning_amber_rounded,
          backgroundColor: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFF57C00),
        );

      case LessonContentType.quote:
        return _QuoteBlock(block: block);

      case LessonContentType.bulletList:
        return _ListBlock(block: block, numbered: false);

      case LessonContentType.numberedList:
        return _ListBlock(block: block, numbered: true);

      case LessonContentType.divider:
        return const _DividerBlock();

      case LessonContentType.summary:
        return _SummaryBlock(block: block);

      case LessonContentType.keyTakeaways:
        return _KeyTakeawaysBlock(block: block);

      case LessonContentType.knowledgeCheck:
        return _KnowledgeCheckBlock(block: block);

      case LessonContentType.image:
        return _ImageBlock(block: block);

      case LessonContentType.video:
        return _VideoBlock(block: block);
    }
  }
}

class _HeadingBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _HeadingBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Text(
        block.title,
        style: TextStyle(
          fontSize: 21,
          height: 1.25,
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _ParagraphBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _ParagraphBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.isNotEmpty) ...[
          Text(
            block.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          block.content,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HighlightedBlock extends StatelessWidget {
  final LessonContentBlock block;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _HighlightedBlock({
    required this.block,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.title.isNotEmpty) ...[
                  Text(
                    block.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                if (block.content.isNotEmpty)
                  Text(
                    block.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: cs.onSurface,
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

class _QuoteBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _QuoteBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: cs.primary, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              block.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  final LessonContentBlock block;
  final bool numbered;

  const _ListBlock({required this.block, required this.numbered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = block.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.isNotEmpty) ...[
          Text(
            block.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ...List.generate(items.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: numbered
                      ? Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        )
                      : Icon(Icons.circle, size: 8, color: cs.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DividerBlock extends StatelessWidget {
  const _DividerBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _SummaryBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_outlined, color: cs.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                block.title.isEmpty ? 'Lesson Summary' : block.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
          if (block.content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              block.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: cs.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyTakeawaysBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _KeyTakeawaysBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'Key Takeaways',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...block.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeCheckBlock extends StatefulWidget {
  final LessonContentBlock block;

  const _KnowledgeCheckBlock({required this.block});

  @override
  State<_KnowledgeCheckBlock> createState() => _KnowledgeCheckBlockState();
}

class _KnowledgeCheckBlockState extends State<_KnowledgeCheckBlock> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final block = widget.block;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_alt_outlined, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                block.title.isEmpty ? 'Knowledge Check' : block.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
          if (_showAnswer && block.caption != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                block.caption!,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showAnswer = !_showAnswer;
              });
            },
            icon: Icon(
              _showAnswer
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(_showAnswer ? 'Hide Answer' : 'Show Answer'),
          ),
        ],
      ),
    );
  }
}

class _ImageBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _ImageBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mediaUrl = block.mediaUrl;

    if (mediaUrl == null || mediaUrl.isEmpty) {
      return const _MissingMediaCard(
        icon: Icons.image_not_supported_outlined,
        message: 'Lesson image is unavailable.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: mediaUrl.startsWith('assets/')
              ? Image.asset(
                  mediaUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const _MissingMediaCard(
                      icon: Icons.broken_image_outlined,
                      message: 'Unable to display this image.',
                    );
                  },
                )
              : Image.network(
                  mediaUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const _MissingMediaCard(
                      icon: Icons.broken_image_outlined,
                      message: 'Unable to display this image.',
                    );
                  },
                ),
        ),
        if (block.caption != null) ...[
          const SizedBox(height: 7),
          Text(
            block.caption!,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _VideoBlock extends StatelessWidget {
  final LessonContentBlock block;

  const _VideoBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: cs.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title.isEmpty ? 'Video Lesson' : block.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Video playback will be connected in a later phase.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
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

class _MissingMediaCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MissingMediaCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
