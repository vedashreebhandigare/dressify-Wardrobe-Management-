import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';
import '../../../../shared/providers/wardrobe_providers.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  Future<void> _wearToday(ClothingItem item) async {
    await ref.read(wardrobeListProvider.notifier).markAsWorn(item.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text("Logged as worn today! (${item.wearCount + 1}x)"),
          ]),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _delete(ClothingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Item?'),
        content: Text('Are you sure you want to remove "${item.name.isNotEmpty ? item.name : item.category}" from your wardrobe?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(wardrobeListProvider.notifier).deleteItem(item.id);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeListProvider);
    final item = wardrobe.where((i) => i.id == widget.itemId).firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                  child: Icon(
                    item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: item.isFavorite ? AppTheme.secondary : AppTheme.textSecondary,
                  ),
                ),
                onPressed: () => ref.read(wardrobeListProvider.notifier).toggleFavorite(item.id),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                ),
                onPressed: () => _delete(item),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'clothing-${item.id}',
                child: Container(
                  color: AppTheme.surfaceVariant,
                  child: item.imagePath.isNotEmpty
                      ? Image.file(File(item.imagePath), fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(_categoryEmoji(item.category),
                                style: const TextStyle(fontSize: 80)),
                          ))
                      : Center(
                          child: Text(_categoryEmoji(item.category),
                              style: const TextStyle(fontSize: 80)),
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name.isNotEmpty ? item.name : item.category,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ),
                      if (item.brand.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(item.brand, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Tag chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TagChip(label: item.category, icon: Icons.category_rounded, color: AppTheme.primary),
                      _TagChip(label: item.color, icon: Icons.palette_rounded, color: AppTheme.secondary),
                      _TagChip(label: item.season, icon: Icons.thermostat_rounded, color: AppTheme.accent),
                      _TagChip(label: item.occasion, icon: Icons.event_rounded, color: AppTheme.success),
                      _TagChip(label: item.pattern, icon: Icons.texture_rounded, color: AppTheme.warning),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _StatBox(
                        value: '${item.wearCount}',
                        label: 'Times Worn',
                        icon: Icons.repeat_rounded,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: item.lastWornDate != null
                            ? DateFormat('MMM d').format(item.lastWornDate!)
                            : 'Never',
                        label: 'Last Worn',
                        icon: Icons.calendar_today_rounded,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: DateFormat('MMM d').format(item.createdAt),
                        label: 'Added',
                        icon: Icons.add_circle_outline_rounded,
                        color: AppTheme.secondary,
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(item.notes, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                    ).animate().fadeIn(delay: 400.ms),
                  ],

                  if (item.isUnused) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_empty_rounded, color: AppTheme.warning),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'This item hasn\'t been worn in over 90 days. Consider wearing or donating it!',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _wearToday(item),
                      icon: const Icon(Icons.checkroom_rounded),
                      label: const Text('Mark as Worn Today'),
                    ).animate().fadeIn(delay: 600.ms),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    const map = {
      'Tops': '👕', 'Bottoms': '👖', 'Dresses': '👗', 'Outerwear': '🧥',
      'Shoes': '👟', 'Accessories': '👜', 'Activewear': '🏃', 'Formal': '👔',
    };
    return map[category] ?? '👗';
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TagChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
