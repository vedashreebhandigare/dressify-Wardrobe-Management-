import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/outfit_providers.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../features/outfits/data/models/outfit_model.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';

class OutfitSuggestionsScreen extends ConsumerStatefulWidget {
  const OutfitSuggestionsScreen({super.key});

  @override
  ConsumerState<OutfitSuggestionsScreen> createState() => _OutfitSuggestionsScreenState();
}

class _OutfitSuggestionsScreenState extends ConsumerState<OutfitSuggestionsScreen> {
  String _selectedOccasion = 'Casual';
  String _selectedSeason = 'All Season';
  bool _isGenerating = false;

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    final wardrobe = ref.read(wardrobeListProvider);
    await ref.read(outfitListProvider.notifier).generateTodayOutfit(
      wardrobe: wardrobe,
      occasion: _selectedOccasion,
      season: _selectedSeason,
    );
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    final savedOutfits = ref.watch(savedOutfitsProvider);
    final allOutfits = ref.watch(outfitListProvider);
    final aiOutfits = allOutfits.where((o) => o.isAIGenerated).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _OutfitHeader(
              onGenerate: _generate,
              isGenerating: _isGenerating,
              selectedOccasion: _selectedOccasion,
              selectedSeason: _selectedSeason,
              onOccasionChanged: (v) => setState(() => _selectedOccasion = v),
              onSeasonChanged: (v) => setState(() => _selectedSeason = v),
            ).animate().fadeIn(duration: 500.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI Generated', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('${aiOutfits.length} looks', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),

          aiOutfits.isEmpty
              ? SliverToBoxAdapter(
                  child: _EmptyState(onGenerate: _generate),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _OutfitCard(
                        outfit: aiOutfits[index],
                        index: index,
                      ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.1);
                    },
                    childCount: aiOutfits.length,
                  ),
                ),

          if (savedOutfits.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Saved Outfits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${savedOutfits.length} saved', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _OutfitCard(outfit: savedOutfits[index], index: index),
                childCount: savedOutfits.length,
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

class _OutfitHeader extends StatelessWidget {
  final VoidCallback onGenerate;
  final bool isGenerating;
  final String selectedOccasion;
  final String selectedSeason;
  final ValueChanged<String> onOccasionChanged;
  final ValueChanged<String> onSeasonChanged;

  const _OutfitHeader({
    required this.onGenerate,
    required this.isGenerating,
    required this.selectedOccasion,
    required this.selectedSeason,
    required this.onOccasionChanged,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FCD), Color(0xFFF48FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 28, color: Colors.white),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Outfit Generator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Styled for you', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _GlassDropdown(
                  value: selectedOccasion,
                  items: AppConstants.occasions,
                  label: 'Occasion',
                  onChanged: onOccasionChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassDropdown(
                  value: selectedSeason,
                  items: AppConstants.seasons,
                  label: 'Season',
                  onChanged: onSeasonChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: isGenerating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(isGenerating ? 'Styling...' : 'Generate New Outfit',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String> onChanged;

  const _GlassDropdown({
    required this.value, required this.items, required this.label, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppTheme.primary,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.expand_more_rounded, color: Colors.white, size: 18),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white)))).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _OutfitCard extends ConsumerWidget {
  final OutfitModel outfit;
  final int index;

  const _OutfitCard({required this.outfit, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(outfitItemsProvider(outfit));
    final notifier = ref.read(outfitListProvider.notifier);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(outfit.occasion, style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          if (outfit.isAIGenerated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppTheme.heroGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('AI', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    outfit.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: outfit.isSaved ? AppTheme.primary : AppTheme.textHint,
                  ),
                  onPressed: () {
                    notifier.saveOutfit(outfit.copyWith(isSaved: !outfit.isSaved));
                  },
                ),
              ],
            ),
          ),

          // Items Row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: items.isEmpty
                ? Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('Add clothes to your wardrobe first')),
                  )
                : Row(
                    children: items.take(4).map((item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _OutfitItemTile(item: item),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OutfitItemTile extends StatelessWidget {
  final ClothingItem item;
  const _OutfitItemTile({required this.item});

  Widget _buildSmartImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(_categoryIcon(item.category), size: 32, color: AppTheme.textHint),
        ));
    }
    return Image.asset(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(_categoryIcon(item.category), size: 32, color: AppTheme.textHint),
      ));
  }

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
    return Column(
      children: [
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: item.imagePath.isNotEmpty
                ? _buildSmartImage(item.imagePath)
                : Center(
                    child: Icon(_categoryIcon(item.category), size: 32, color: AppTheme.textHint),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.category,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 56, color: AppTheme.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No outfits yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Select an occasion and season, then hit Generate to get your first AI outfit!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Generate My First Outfit'),
          ),
        ],
      ),
    );
  }
}
