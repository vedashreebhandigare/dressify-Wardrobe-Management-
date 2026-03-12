import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';
import '../../../../core/theme/app_theme.dart';

class ClothingCard extends ConsumerWidget {
  final ClothingItem item;
  final VoidCallback onTap;

  const ClothingCard({super.key, required this.item, required this.onTap});

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppTheme.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: _hexToColor(item.colorHex).withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: item.imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(_categoryEmoji(item.category),
                                  style: const TextStyle(fontSize: 48)),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(_categoryEmoji(item.category),
                              style: const TextStyle(fontSize: 48)),
                        ),
                ),
                if (item.isFavorite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppTheme.secondary, size: 14),
                    ),
                  ),
                if (item.isUnused)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Unused',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isNotEmpty ? item.name : item.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _hexToColor(item.colorHex),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.color,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rotate_left_rounded, size: 13, color: AppTheme.textHint),
                          const SizedBox(width: 3),
                          Text(
                            '${item.wearCount}x',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.season,
                          style: const TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    const map = {
      'Tops': '👕',
      'Bottoms': '👖',
      'Dresses': '👗',
      'Outerwear': '🧥',
      'Shoes': '👟',
      'Accessories': '👜',
      'Activewear': '🏃',
      'Formal': '👔',
      'Sleepwear': '🛏️',
    };
    return map[category] ?? '👗';
  }
}
