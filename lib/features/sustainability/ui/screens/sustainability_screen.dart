import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';

class SustainabilityScreen extends ConsumerWidget {
  const SustainabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(wardrobeListProvider);
    final stats = ref.watch(wardrobeStatsProvider);
    final unusedItems = allItems.where((i) => i.isUnused).toList();

    final categoryDist = <String, int>{};
    for (final item in allItems) {
      categoryDist[item.category] = (categoryDist[item.category] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _EcoHeader(stats: stats).animate().fadeIn(duration: 500.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _InsightCards(stats: stats, unusedItems: unusedItems)
                  .animate().fadeIn(delay: 200.ms),
            ),
          ),

          if (allItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _WardrobeDonut(categoryDist: categoryDist, stats: stats)
                    .animate().fadeIn(delay: 300.ms),
              ),
            ),
          ],

          if (unusedItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_empty_rounded, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    const Text('Forgotten Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${unusedItems.length} items', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _UnusedItemTile(
                  item: unusedItems[index],
                  onTap: () => context.push('/item/${unusedItems[index].id}'),
                ).animate(delay: (index * 60 + 400).ms).fadeIn().slideX(begin: 0.05),
                childCount: unusedItems.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _EcoHeader extends StatelessWidget {
  final WardrobeStats stats;
  const _EcoHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DB6AC), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4DB6AC).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco_rounded, size: 28, color: Colors.white),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sustainability', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Your eco fashion impact', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.usagePercent.toStringAsFixed(0)}% worn',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const Text('of your wardrobe this period', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: stats.usagePercent / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _InsightCards extends StatelessWidget {
  final WardrobeStats stats;
  final List<ClothingItem> unusedItems;

  const _InsightCards({required this.stats, required this.unusedItems});

  @override
  Widget build(BuildContext context) {
    final insights = <_Insight>[
      if (stats.total > 0)
        _Insight(
          emoji: '📊',
          text: 'You have ${stats.total} items in your wardrobe',
          color: AppTheme.primary,
          subtitle: 'Keep building your digital closet',
        ),
      if (stats.usagePercent >= 80)
        _Insight(
          emoji: '🏆',
          text: 'Amazing! You wear ${stats.usagePercent.toStringAsFixed(0)}% of your wardrobe',
          color: AppTheme.success,
          subtitle: 'You\'re a sustainable fashion champion!',
        )
      else if (stats.usagePercent >= 50)
        _Insight(
          emoji: '📈',
          text: 'Good progress! ${stats.usagePercent.toStringAsFixed(0)}% wardrobe usage',
          color: AppTheme.warning,
          subtitle: 'Try wearing some forgotten items',
        )
      else
        _Insight(
          emoji: '💡',
          text: 'Only ${stats.usagePercent.toStringAsFixed(0)}% of clothes are worn',
          color: AppTheme.error,
          subtitle: 'Discover your forgotten wardrobe',
        ),
      if (unusedItems.isNotEmpty)
        _Insight(
          emoji: '⚠️',
          text: '${unusedItems.length} items haven\'t been worn in 90+ days',
          color: AppTheme.warning,
          subtitle: 'Consider donating or wearing them soon',
        ),
      const _Insight(
        emoji: '🌍',
        text: 'Every extra wear = less fast fashion waste',
        color: Color(0xFF4DB6AC),
        subtitle: 'You\'re making a positive impact!',
      ),
    ];

    return Column(
      children: insights
          .map((insight) => _InsightCard(insight: insight))
          .toList(),
    );
  }
}

class _Insight {
  final String emoji;
  final String text;
  final Color color;
  final String subtitle;

  const _Insight({required this.emoji, required this.text, required this.color, required this.subtitle});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: insight.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: insight.color)),
                const SizedBox(height: 2),
                Text(insight.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _WardrobeDonut extends StatefulWidget {
  final Map<String, int> categoryDist;
  final WardrobeStats stats;

  const _WardrobeDonut({required this.categoryDist, required this.stats});

  @override
  State<_WardrobeDonut> createState() => _WardrobeDonutState();
}

class _WardrobeDonutState extends State<_WardrobeDonut> {
  int _touching = -1;

  static const _colors = [
    AppTheme.primary, AppTheme.secondary, AppTheme.accent, AppTheme.success,
    AppTheme.warning, Color(0xFFCE93D8), Color(0xFF80CBC4), Color(0xFFFFCC02),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = widget.categoryDist.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wardrobe Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: entries.asMap().entries.map((e) {
                        final isTouching = e.key == _touching;
                        return PieChartSectionData(
                          color: _colors[e.key % _colors.length],
                          value: e.value.value.toDouble(),
                          radius: isTouching ? 52 : 44,
                          title: isTouching ? '${e.value.value}' : '',
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions || response == null) {
                              _touching = -1;
                            } else {
                              _touching = response.touchedSection?.touchedSectionIndex ?? -1;
                            }
                          });
                        },
                      ),
                      centerSpaceRadius: 32,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _colors[e.key % _colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${e.value.key} (${e.value.value})',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _UnusedItemTile extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;

  const _UnusedItemTile({required this.item, required this.onTap});

  IconData _categoryIcon(String cat) {
    const map = {
      'Tops': Icons.checkroom_rounded,
      'Bottoms': Icons.straighten_rounded,
      'Dresses': Icons.checkroom_rounded,
      'Outerwear': Icons.checkroom_rounded,
      'Shoes': Icons.ice_skating_rounded,
      'Accessories': Icons.watch_rounded,
    };
    return map[cat] ?? Icons.checkroom_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: AppTheme.warning.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imagePath.isNotEmpty
                    ? _buildSmartImage(item.imagePath)
                    : Center(child: Icon(_categoryIcon(item.category), size: 24, color: AppTheme.warning)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isNotEmpty ? item.name : item.category,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.lastWornDate == null
                        ? 'Never worn since added'
                        : 'Last worn ${_daysSince(item.lastWornDate!)} days ago',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  int _daysSince(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  Widget _buildSmartImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: 48, height: 48,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(_categoryIcon(item.category), size: 24, color: AppTheme.warning),
        ));
    }
    return Image.asset(path, fit: BoxFit.cover, width: 48, height: 48,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(_categoryIcon(item.category), size: 24, color: AppTheme.warning),
      ));
  }
}
