import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_wardrobe/core/theme/app_theme.dart';
import 'package:smart_wardrobe/features/wardrobe/data/models/fashion_models.dart';

class WardrobeShelf extends StatelessWidget {
  final String title;
  final List<ClothingItem> items;
  final Function(ClothingItem) onItemTap;

  const WardrobeShelf({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => onItemTap(item),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: item.imagePath.isNotEmpty
                              ? Image.file(
                                  File(item.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.checkroom_rounded,
                                        color: Colors.grey, size: 40),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.checkroom_rounded,
                                      color: Colors.grey, size: 40),
                                ),
                        ),
                        // Glassmorphism Gradient Overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (item.isFavorite)
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(Icons.favorite,
                                color: Colors.redAccent, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
