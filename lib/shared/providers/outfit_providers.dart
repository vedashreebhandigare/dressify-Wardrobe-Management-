import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/outfits/data/models/outfit_model.dart';
import '../../../features/outfits/data/repositories/outfit_repository.dart';
import '../../../features/wardrobe/data/models/clothing_item.dart';
import 'wardrobe_providers.dart';

final outfitListProvider = StateNotifierProvider<OutfitNotifier, List<OutfitModel>>((ref) {
  final repo = ref.watch(outfitRepositoryProvider);
  return OutfitNotifier(repo);
});

class OutfitNotifier extends StateNotifier<List<OutfitModel>> {
  final OutfitRepository _repository;

  OutfitNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllOutfits();
  }

  Future<void> saveOutfit(OutfitModel outfit) async {
    await _repository.saveOutfit(outfit);
    _load();
  }

  Future<void> deleteOutfit(String id) async {
    await _repository.deleteOutfit(id);
    _load();
  }

  Future<OutfitModel?> generateTodayOutfit({
    required List<ClothingItem> wardrobe,
    String occasion = 'Casual',
    String season = 'All Season',
  }) async {
    final outfit = _repository.generateOutfitSuggestion(
      wardrobe: wardrobe,
      occasion: occasion,
      season: season,
    );
    if (outfit.clothingItemIds.isNotEmpty) {
      await _repository.saveOutfit(outfit);
      _load();
      return outfit;
    }
    return null;
  }
}

final todayOutfitProvider = Provider<OutfitModel?>((ref) {
  final outfits = ref.watch(outfitListProvider);
  final today = DateTime.now();
  try {
    return outfits.firstWhere((o) =>
      o.date.year == today.year &&
      o.date.month == today.month &&
      o.date.day == today.day &&
      o.isAIGenerated
    );
  } catch (_) {
    return null;
  }
});

final savedOutfitsProvider = Provider<List<OutfitModel>>((ref) {
  final outfits = ref.watch(outfitListProvider);
  return outfits.where((o) => o.isSaved).toList();
});

final historyOutfitsProvider = Provider<List<OutfitModel>>((ref) {
  final outfits = ref.watch(outfitListProvider);
  return outfits
    ..sort((a, b) => b.date.compareTo(a.date));
});

final outfitItemsProvider = Provider.family<List<ClothingItem>, OutfitModel>((ref, outfit) {
  final wardrobe = ref.watch(wardrobeListProvider);
  return wardrobe.where((item) => outfit.clothingItemIds.contains(item.id)).toList();
});
