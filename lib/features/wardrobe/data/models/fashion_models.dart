import 'package:flutter/foundation.dart';

enum ClothingCategory { tops, bottoms, dresses, shoes, accessories, outerwear }

enum ClothingLayer { top, bottom, shoes, hair, accessory }

class ClothingItem {
  final String id;
  final String name;
  final String imagePath;
  final ClothingCategory category;
  final ClothingLayer layer;
  final String color;
  final String occasion;
  final String season;
  final bool isFavorite;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.layer,
    this.color = 'Multi',
    this.occasion = 'Casual',
    this.season = 'All',
    this.isFavorite = false,
  });

  // Helper to convert from String (legacy data) to Enum
  static ClothingCategory parseCategory(String category) {
    try {
      return ClothingCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == category.toLowerCase(),
        orElse: () => ClothingCategory.tops,
      );
    } catch (_) {
      return ClothingCategory.tops;
    }
  }
}

class Hairstyle {
  final String id;
  final String name;
  final String imagePath;
  final double offsetX;
  final double offsetY;
  final double scale;

  const Hairstyle({
    required this.id,
    required this.name,
    required this.imagePath,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.scale = 1.0,
  });
}

class Avatar {
  final String? faceImagePath;
  final String bodyImagePath;

  const Avatar({
    this.faceImagePath,
    this.bodyImagePath = 'assets/avatar/body.png',
  });

  Avatar copyWith({String? faceImagePath, String? bodyImagePath}) {
    return Avatar(
      faceImagePath: faceImagePath ?? this.faceImagePath,
      bodyImagePath: bodyImagePath ?? this.bodyImagePath,
    );
  }
}
