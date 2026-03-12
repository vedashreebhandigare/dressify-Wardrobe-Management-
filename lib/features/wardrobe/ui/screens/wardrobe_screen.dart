import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../shared/providers/outfit_providers.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';
import '../widgets/clothing_card.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AppConstants.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = ref.watch(filteredWardrobeProvider);
    final stats = ref.watch(wardrobeStatsProvider);
    final todayOutfit = ref.watch(todayOutfitProvider);
    final allItems = ref.watch(wardrobeListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverToBoxAdapter(
            child: _HeroHeader(stats: stats).animate().fadeIn(duration: 600.ms),
          ),

          // Today's Outfit Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _TodayOutfitCard(
                outfitItems: todayOutfit != null
                    ? allItems.where((i) => todayOutfit.clothingItemIds.contains(i.id)).toList()
                    : [],
                onGenerate: () async {
                  final notifier = ref.read(outfitListProvider.notifier);
                  await notifier.generateTodayOutfit(wardrobe: allItems);
                },
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _StatsRow(stats: stats).animate().fadeIn(delay: 300.ms),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Wardrobe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      Text('${filteredItems.length} items', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                _SearchBar(),
                const SizedBox(height: 12),
                _CategoryFilter(),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Grid
          filteredItems.isEmpty
              ? SliverFillRemaining(child: _EmptyWardrobe())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ClothingCard(
                        item: filteredItems[index],
                        onTap: () => context.push('/item/${filteredItems[index].id}'),
                      ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1);
                    },
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final WardrobeStats stats;
  const _HeroHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning! 👋',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SmartWardrobe',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeroStat(
                label: 'Items',
                value: '${stats.total}',
                icon: Icons.checkroom_rounded,
              ),
              const SizedBox(width: 16),
              _HeroStat(
                label: 'Outfits',
                value: stats.usagePercent.toStringAsFixed(0) + '%',
                icon: Icons.auto_awesome_rounded,
              ),
              const SizedBox(width: 16),
              _HeroStat(
                label: 'Unused',
                value: '${stats.unused}',
                icon: Icons.hourglass_empty_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _TodayOutfitCard extends StatelessWidget {
  final List<ClothingItem> outfitItems;
  final VoidCallback onGenerate;

  const _TodayOutfitCard({required this.outfitItems, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text("Today's Outfit", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
              GestureDetector(
                onTap: onGenerate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (outfitItems.isEmpty)
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Tap "Generate" to get your AI outfit suggestion ✨',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: outfitItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = outfitItems[index];
                  return Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: item.imagePath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(item.imagePath, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.checkroom_rounded, color: AppTheme.primary, size: 28)),
                              )
                            : const Icon(Icons.checkroom_rounded, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(item.category, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final WardrobeStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          title: 'Wardrobe Usage',
          value: '${stats.usagePercent.toStringAsFixed(0)}%',
          icon: Icons.pie_chart_rounded,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Favorites',
          value: '${stats.favorites}',
          icon: Icons.favorite_rounded,
          color: AppTheme.secondary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Unworn',
          value: '${stats.unused}',
          icon: Icons.hourglass_disabled_rounded,
          color: AppTheme.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textHint),
          hintText: 'Search clothes...',
        ),
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.25)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _EmptyWardrobe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Your wardrobe is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first clothing item',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
