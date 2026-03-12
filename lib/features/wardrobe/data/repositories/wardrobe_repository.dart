import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_wardrobe/features/wardrobe/data/models/clothing_item.dart';
import 'package:smart_wardrobe/core/constants/app_constants.dart';

class WardrobeRepository {
  late Box<ClothingItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ClothingItem>(AppConstants.hiveBoxWardrobe);
  }

  List<ClothingItem> getAllItems() => _box.values.toList();

  ClothingItem? getItem(String id) {
    try {
      return _box.values.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addItem(ClothingItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(ClothingItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  Future<void> markAsWorn(String id) async {
    final item = getItem(id);
    if (item != null) {
      final updated = item.copyWith(
        wearCount: item.wearCount + 1,
        lastWornDate: DateTime.now(),
      );
      await _box.put(id, updated);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final item = getItem(id);
    if (item != null) {
      final updated = item.copyWith(isFavorite: !item.isFavorite);
      await _box.put(id, updated);
    }
  }

  List<ClothingItem> filterByCategory(String category) {
    if (category == 'All') return getAllItems();
    return _box.values.where((item) => item.category == category).toList();
  }

  List<ClothingItem> filterBySeason(String season) {
    if (season == 'All Season') return getAllItems();
    return _box.values.where((item) => item.season == season).toList();
  }

  List<ClothingItem> filterByColor(String color) {
    return _box.values.where((item) => item.color == color).toList();
  }

  List<ClothingItem> searchItems(String query) {
    final q = query.toLowerCase();
    return _box.values.where((item) =>
      item.category.toLowerCase().contains(q) ||
      item.color.toLowerCase().contains(q) ||
      item.brand.toLowerCase().contains(q) ||
      item.name.toLowerCase().contains(q)
    ).toList();
  }

  List<ClothingItem> getUnusedItems() {
    return _box.values.where((item) => item.isUnused).toList();
  }

  List<ClothingItem> getMostWorn({int limit = 5}) {
    final items = _box.values.toList()
      ..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    return items.take(limit).toList();
  }

  List<ClothingItem> getLeastWorn({int limit = 5}) {
    final items = _box.values.toList()
      ..sort((a, b) => a.wearCount.compareTo(b.wearCount));
    return items.take(limit).toList();
  }

  Map<String, int> getCategoryDistribution() {
    final map = <String, int>{};
    for (final item in _box.values) {
      map[item.category] = (map[item.category] ?? 0) + 1;
    }
    return map;
  }

  double getWardrobeUsagePercent() {
    final total = _box.values.length;
    if (total == 0) return 0;
    final used = _box.values.where((item) => item.wearCount > 0).length;
    return (used / total) * 100;
  }
}

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});
