import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genius Academy Premium'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 48,
                backgroundColor:
                    const Color(0xFFF57C00).withValues(alpha: 0.15),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 56,
                  color: Color(0xFFF57C00),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Premium Features Coming Soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'More categories, extra practice packs, and video explanations will be available in a future update.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              const _PremiumFeature(
                icon: Icons.grid_view_rounded,
                title: 'Patterns Category',
              ),
              const _PremiumFeature(
                icon: Icons.more_horiz_rounded,
                title: 'Additional IQ Categories',
              ),
              const _PremiumFeature(
                icon: Icons.school_rounded,
                title: 'Video Explanations',
              ),
              const _PremiumFeature(
                icon: Icons.psychology_alt_rounded,
                title: 'Additional Practice Packs',
              ),

              const SizedBox(height: 28),

              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium features are coming in a future update.'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Maybe Later'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PremiumFeature({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}