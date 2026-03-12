import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_wardrobe/features/outfits/data/models/outfit_model.dart';
import 'package:smart_wardrobe/features/wardrobe/data/models/clothing_item.dart';
import 'package:smart_wardrobe/core/constants/app_constants.dart';

class OutfitRepository {
  late Box<OutfitModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<OutfitModel>(AppConstants.hiveBoxOutfits);
  }

  List<OutfitModel> getAllOutfits() => _box.values.toList();

  OutfitModel? getOutfit(String id) {
    try {
      return _box.values.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOutfit(OutfitModel outfit) async {
    await _box.put(outfit.id, outfit);
  }

  Future<void> deleteOutfit(String id) async {
    await _box.delete(id);
  }

  List<OutfitModel> getSavedOutfits() {
    return _box.values.where((o) => o.isSaved).toList();
  }

  List<OutfitModel> getAIOutfits() {
    return _box.values.where((o) => o.isAIGenerated).toList();
  }

  OutfitModel? getTodayOutfit() {
    final today = DateTime.now();
    try {
      return _box.values.firstWhere((o) =>
        o.date.year == today.year &&
        o.date.month == today.month &&
        o.date.day == today.day &&
        o.isAIGenerated
      );
    } catch (_) {
      return null;
    }
  }

  List<OutfitModel> getOutfitsInRange(DateTime start, DateTime end) {
    return _box.values.where((o) =>
      o.date.isAfter(start.subtract(const Duration(days: 1))) &&
      o.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Generate an AI outfit suggestion from available items
  OutfitModel generateOutfitSuggestion({
    required List<ClothingItem> wardrobe,
    String occasion = 'Casual',
    String season = 'All Season',
  }) {
    ClothingItem? findItem(String category) {
      final candidates = wardrobe.where((item) =>
        item.category == category &&
        (item.season == season || item.season == 'All Season') &&
        (occasion == 'Casual' || item.occasion == occasion)
      ).toList();
      if (candidates.isEmpty) return null;
      candidates.sort((a, b) => a.wearCount.compareTo(b.wearCount));
      return candidates.first;
    }

    final ids = <String>[];

    final top = findItem('Tops') ??
        (wardrobe.where((i) => i.category == 'Tops').isNotEmpty
            ? (wardrobe.where((i) => i.category == 'Tops').toList()
                ..sort((a, b) => a.wearCount.compareTo(b.wearCount))).first
            : null);
    final bottom = findItem('Bottoms') ??
        (wardrobe.where((i) => i.category == 'Bottoms').isNotEmpty
            ? (wardrobe.where((i) => i.category == 'Bottoms').toList()
                ..sort((a, b) => a.wearCount.compareTo(b.wearCount))).first
            : null);
    final shoes = findItem('Shoes') ??
        (wardrobe.where((i) => i.category == 'Shoes').isNotEmpty
            ? (wardrobe.where((i) => i.category == 'Shoes').toList()
                ..sort((a, b) => a.wearCount.compareTo(b.wearCount))).first
            : null);
    final accessory = findItem('Accessories') ??
        (wardrobe.where((i) => i.category == 'Accessories').isNotEmpty
            ? wardrobe.where((i) => i.category == 'Accessories').first
            : null);

    if (top != null) ids.add(top.id);
    if (bottom != null) ids.add(bottom.id);
    if (shoes != null) ids.add(shoes.id);
    if (accessory != null) ids.add(accessory.id);

    const occasionNames = {
      'Casual': 'Chill & Casual',
      'Work': 'Work Ready',
      'Formal': 'Formal Look',
      'Party': 'Party Night',
      'Date Night': 'Date Night Glam',
    };

    return OutfitModel(
      clothingItemIds: ids,
      date: DateTime.now(),
      occasion: occasion,
      name: occasionNames[occasion] ?? 'AI Styled Look',
      isAIGenerated: true,
    );
  }
}

final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  return OutfitRepository();
});
