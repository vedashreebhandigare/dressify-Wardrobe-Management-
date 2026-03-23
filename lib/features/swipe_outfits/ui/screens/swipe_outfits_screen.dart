import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../shared/providers/outfit_providers.dart';
import '../../../../features/outfits/data/repositories/outfit_repository.dart';
import '../../../../features/outfits/data/models/outfit_model.dart';

class SwipeOutfitsScreen extends ConsumerStatefulWidget {
  const SwipeOutfitsScreen({super.key});

  @override
  ConsumerState<SwipeOutfitsScreen> createState() => _SwipeOutfitsScreenState();
}

class _SwipeOutfitsScreenState extends ConsumerState<SwipeOutfitsScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<OutfitModel> generatedOutfits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateBatch();
  }

  void _generateBatch() {
    final wardrobe = ref.read(wardrobeListProvider);
    if (wardrobe.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final repo = ref.read(outfitRepositoryProvider);
    final occasions = ['Casual', 'Work', 'Party', 'Date Night'];
    final newBatch = <OutfitModel>[];

    for (int i = 0; i < 5; i++) {
        final occasion = occasions[i % occasions.length];
        newBatch.add(repo.generateOutfitSuggestion(
            wardrobe: wardrobe, 
            occasion: occasion,
        ));
    }

    setState(() {
      generatedOutfits = newBatch;
      isLoading = false;
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      // Save outfit
      final outfit = generatedOutfits[previousIndex];
      ref.read(outfitRepositoryProvider).saveOutfit(outfit.copyWith(isSaved: true));
      ref.invalidate(outfitListProvider);
      ref.invalidate(savedOutfitsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved!'), backgroundColor: AppTheme.success, duration: Duration(seconds: 1)),
      );
    }
    return true;
  }

  void _onEnd() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), _generateBatch);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (generatedOutfits.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: Text('Add clothing items to your wardrobe first!')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Outfit Inspiration', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Swipe right to save, left to skip',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
            Expanded(
              child: CardSwiper(
                controller: controller,
                cardsCount: generatedOutfits.length,
                onSwipe: _onSwipe,
                onEnd: _onEnd,
                padding: const EdgeInsets.all(24.0),
                numberOfCardsDisplayed: generatedOutfits.length > 2 ? 3 : generatedOutfits.length,
                backCardOffset: const Offset(0, 40),
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  return _SwipeCard(outfit: generatedOutfits[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SwipeButton(
                    icon: Icons.close_rounded,
                    color: AppTheme.error,
                    onTap: () => controller.swipe(CardSwiperDirection.left),
                  ).animate().scale(delay: 200.ms),
                  _SwipeButton(
                    icon: Icons.favorite_rounded,
                    color: AppTheme.success,
                    onTap: () => controller.swipe(CardSwiperDirection.right),
                  ).animate().scale(delay: 300.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SwipeButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

class _SwipeCard extends ConsumerWidget {
  final OutfitModel outfit;
  const _SwipeCard({required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(outfitItemsProvider(outfit));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Items Grid
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  outfit.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    outfit.occasion,
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: item.imagePath.isNotEmpty
                                    ? _buildSmartImage(item.imagePath)
                                    : Center(
                                        child: Icon(
                                          _getCategoryIcon(item.category),
                                          size: 40,
                                          color: AppTheme.textHint,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.name.isNotEmpty ? item.name : item.category,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: double.infinity,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.checkroom_rounded, size: 40, color: AppTheme.textHint),
        ));
    }
    return Image.asset(path, fit: BoxFit.cover, width: double.infinity,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(Icons.checkroom_rounded, size: 40, color: AppTheme.textHint),
      ));
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tops': return Icons.checkroom_rounded;
      case 'Bottoms': return Icons.straighten_rounded;
      case 'Dresses': return Icons.checkroom_rounded;
      case 'Outerwear': return Icons.checkroom_rounded;
      case 'Shoes': return Icons.ice_skating_rounded;
      case 'Accessories': return Icons.watch_rounded;
      case 'Activewear': return Icons.fitness_center_rounded;
      default: return Icons.checkroom_rounded;
    }
  }
}
