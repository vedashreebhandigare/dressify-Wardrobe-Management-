import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/outfit_providers.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../features/outfits/data/models/outfit_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfits = ref.watch(historyOutfitsProvider);
    final stats = ref.watch(wardrobeStatsProvider);

    // Group by month
    final Map<String, List<OutfitModel>> grouped = {};
    for (final outfit in outfits) {
      final key = DateFormat('MMMM yyyy').format(outfit.date);
      grouped.putIfAbsent(key, () => []).add(outfit);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HistoryHeader(stats: stats).animate().fadeIn(duration: 500.ms),
          ),

          if (outfits.isEmpty)
            SliverFillRemaining(child: _EmptyHistory())
          else
            ...grouped.entries.map((entry) => _MonthSection(
              month: entry.key,
              outfits: entry.value,
              ref: ref,
            )).expand((widgets) => widgets),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

List<Widget> _MonthSection({
  required String month,
  required List<OutfitModel> outfits,
  required WidgetRef ref,
}) {
  return [
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Text(month, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final outfit = outfits[index];
          final items = ref.watch(outfitItemsProvider(outfit));
          return _HistoryTile(outfit: outfit, itemCount: items.length)
              .animate(delay: (index * 60).ms).fadeIn().slideX(begin: -0.05);
        },
        childCount: outfits.length,
      ),
    ),
  ];
}

class _HistoryHeader extends StatelessWidget {
  final WardrobeStats stats;
  const _HistoryHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FCD), Color(0xFF4DB6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Outfit History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const Text('Your style journey', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              children: [
                _HistoryStat(label: 'Most Worn', value: stats.mostWorn?.category ?? 'N/A'),
                const SizedBox(width: 12),
                _HistoryStat(label: 'Wardrobe Used', value: '${stats.usagePercent.toStringAsFixed(0)}%'),
                const SizedBox(width: 12),
                _HistoryStat(label: 'Unused Items', value: '${stats.unused}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  final String label;
  final String value;
  const _HistoryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  final OutfitModel outfit;
  final int itemCount;
  const _HistoryTile({required this.outfit, required this.itemCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Date circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(outfit.date),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  DateFormat('MMM').format(outfit.date),
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _TagPill(outfit.occasion, AppTheme.primary),
                    const SizedBox(width: 6),
                    _TagPill('$itemCount pieces', AppTheme.accent),
                    if (outfit.isAIGenerated) ...[
                      const SizedBox(width: 6),
                      _TagPill('AI', AppTheme.secondary),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (outfit.isSaved)
            const Icon(Icons.bookmark_rounded, color: AppTheme.primary, size: 18),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color color;
  const _TagPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 56, color: AppTheme.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No history yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          const SizedBox(height: 8),
          const Text(
            'Generate outfits and track what you wear to build your style history.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
