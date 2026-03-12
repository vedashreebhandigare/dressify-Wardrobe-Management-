import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/wardrobe/data/models/clothing_item.dart';
import '../../../features/wardrobe/data/repositories/wardrobe_repository.dart';

// ── Wardrobe State ────────────────────────────────────────────────────────────

final wardrobeListProvider = StateNotifierProvider<WardrobeNotifier, List<ClothingItem>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return WardrobeNotifier(repo);
});

class WardrobeNotifier extends StateNotifier<List<ClothingItem>> {
  final WardrobeRepository _repository;

  WardrobeNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllItems();
  }

  Future<void> addItem(ClothingItem item) async {
    await _repository.addItem(item);
    _load();
  }

  Future<void> updateItem(ClothingItem item) async {
    await _repository.updateItem(item);
    _load();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    _load();
  }

  Future<void> markAsWorn(String id) async {
    await _repository.markAsWorn(id);
    _load();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    _load();
  }
}

// ── Filter State ──────────────────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedSeasonProvider = StateProvider<String>((ref) => 'All Season');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredWardrobeProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(wardrobeListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final season = ref.watch(selectedSeasonProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return items.where((item) {
    final matchCategory = category == 'All' || item.category == category;
    final matchSeason = season == 'All Season' || item.season == season;
    final matchQuery = query.isEmpty ||
        item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.color.toLowerCase().contains(query) ||
        item.brand.toLowerCase().contains(query);
    return matchCategory && matchSeason && matchQuery;
  }).toList();
});

// ── Stats Providers ─────────────────────────────────────────────────────────

final wardrobeStatsProvider = Provider<WardrobeStats>((ref) {
  final items = ref.watch(wardrobeListProvider);
  final total = items.length;
  final used = items.where((i) => i.wearCount > 0).length;
  final unused = items.where((i) => i.isUnused).length;
  final favorites = items.where((i) => i.isFavorite).length;
  final usagePercent = total == 0 ? 0.0 : (used / total) * 100;

  final sortedByWear = [...items]..sort((a, b) => b.wearCount.compareTo(a.wearCount));

  return WardrobeStats(
    total: total,
    used: used,
    unused: unused,
    favorites: favorites,
    usagePercent: usagePercent,
    mostWorn: sortedByWear.isNotEmpty ? sortedByWear.first : null,
    leastWorn: sortedByWear.isNotEmpty ? sortedByWear.last : null,
  );
});

class WardrobeStats {
  final int total;
  final int used;
  final int unused;
  final int favorites;
  final double usagePercent;
  final ClothingItem? mostWorn;
  final ClothingItem? leastWorn;

  WardrobeStats({
    required this.total,
    required this.used,
    required this.unused,
    required this.favorites,
    required this.usagePercent,
    this.mostWorn,
    this.leastWorn,
  });
}
