import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../shared/providers/outfit_providers.dart';
import '../../../../features/outfits/data/repositories/outfit_repository.dart';
import '../../../../features/outfits/data/models/outfit_model.dart';
import '../../../../features/wardrobe/data/models/fashion_models.dart'
    as fashion;

// Local provider to manage the Avatar state within this screen scope
final avatarProvider = StateProvider<fashion.Avatar>((ref) {
  return const fashion.Avatar(bodyImagePath: 'assets/mannequin/base.png');
});

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  // Selected Items (Using the new Fashion Model)
  fashion.ClothingItem? _selectedTop;
  fashion.ClothingItem? _selectedBottom;
  fashion.ClothingItem? _selectedShoes;
  fashion.Hairstyle? _selectedHair;

  // Mock Hairstyles
  final List<fashion.Hairstyle> _hairstyles = [
    const fashion.Hairstyle(
        id: 'h1',
        name: 'Open Hair',
        imagePath: 'assets/hair/open_hair.png',
        offsetY: -10),
    const fashion.Hairstyle(
        id: 'h2',
        name: 'Ponytail',
        imagePath: 'assets/hair/ponytail.png',
        offsetY: -15),
    const fashion.Hairstyle(
        id: 'h3',
        name: 'Bun',
        imagePath: 'assets/hair/bun.png',
        offsetY: -20,
        scale: 1.1),
  ];

  @override
  void initState() {
    super.initState();
    // Prompt for face photo if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final avatar = ref.read(avatarProvider);
      if (avatar.faceImagePath == null) {
        _showFaceUploadDialog();
      }
    });
  }

  Future<void> _showFaceUploadDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Force choice
      builder: (context) => AlertDialog(
        title: const Text('Visualize Yourself'),
        content: const Text(
            'Upload a face photo to see how outfits look on you. You can crop it to fit the mannequin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Use Default'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickAndCropFace();
            },
            child: const Text('Upload Photo'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndCropFace() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        try {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Align Your Face',
                toolbarColor: AppTheme.primary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
                cropStyle: CropStyle.circle,
              ),
              IOSUiSettings(
                title: 'Align Your Face',
                cropStyle: CropStyle.circle,
              ),
            ],
          );

          if (croppedFile != null) {
            ref
                .read(avatarProvider.notifier)
                .update((state) => state.copyWith(faceImagePath: croppedFile.path));
          }
        } catch (cropError) {
          // Cropping failed — use the original picked image as fallback
          debugPrint('Face cropping failed: $cropError');
          ref
              .read(avatarProvider.notifier)
              .update((state) => state.copyWith(faceImagePath: pickedFile.path));
        }
      }
    } catch (e) {
      debugPrint('Face photo picking failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to pick photo. Please check app permissions.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final rawWardrobe = ref.watch(wardrobeListProvider);

    // Convert raw provider items to our new Fashion Model for the UI
    // This acts as an adapter layer
    // Only include items that have a real image (user-uploaded photos)
    final tops = rawWardrobe
        .where((i) => ['tops', 'outerwear', 'jacket', 'coat']
            .contains(i.category.toLowerCase()))
        .where((i) => i.imagePath.isNotEmpty)
        .map((i) => fashion.ClothingItem(
              id: i.id,
              name: i.name,
              imagePath: i.imagePath,
              category: fashion.ClothingItem.parseCategory(i.category),
              layer: fashion.ClothingLayer.top,
            ))
        .toList();

    final bottoms = rawWardrobe
        .where((i) => ['bottoms', 'pants', 'skirt', 'dresses']
            .contains(i.category.toLowerCase()))
        .where((i) => i.imagePath.isNotEmpty)
        .map((i) => fashion.ClothingItem(
              id: i.id,
              name: i.name,
              imagePath: i.imagePath,
              category: fashion.ClothingItem.parseCategory(i.category),
              layer: fashion.ClothingLayer.bottom,
            ))
        .toList();

    final shoes = rawWardrobe
        .where((i) => ['shoes', 'footwear'].contains(i.category.toLowerCase()))
        .where((i) => i.imagePath.isNotEmpty)
        .map((i) => fashion.ClothingItem(
              id: i.id,
              name: i.name,
              imagePath: i.imagePath,
              category: fashion.ClothingItem.parseCategory(i.category),
              layer: fashion.ClothingLayer.shoes,
            ))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F5),
      appBar: AppBar(
        title: const Text('Outfit Builder',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.face_retouching_natural,
                color: AppTheme.primary),
            onPressed: _pickAndCropFace,
          )
        ],
      ),
      body: Column(
        children: [
          // ----------------------------------------------------
          // 1. Mannequin Layer System
          // ----------------------------------------------------
          Expanded(
            flex: 5,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mannequinHeight = constraints.maxHeight * 0.9;
                  return SizedBox(
                    height: mannequinHeight,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Layer 0: Avatar Body
                        Image.asset(avatar.bodyImagePath,
                                fit: BoxFit.contain, height: mannequinHeight)
                            .animate()
                            .fadeIn(duration: 400.ms),

                        // Layer 1: User Face (Oval Crop)
                        if (avatar.faceImagePath != null)
                          Positioned(
                            top: mannequinHeight * 0.04,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 70,
                                height: 90,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: FileImage(File(avatar.faceImagePath!)),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10)
                                    ]),
                              ).animate().scale(),
                            ),
                          ),

                        // Layer 2: Shoes
                        if (_selectedShoes != null && _selectedShoes!.imagePath.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildLayerImage(_selectedShoes!.imagePath,
                                    height: mannequinHeight * 0.18),
                              ),
                            )
                                .animate(key: ValueKey(_selectedShoes!.id))
                                .fade(),
                          ),

                        // Layer 3: Bottoms
                        if (_selectedBottom != null && _selectedBottom!.imagePath.isNotEmpty)
                          Positioned(
                            top: mannequinHeight * 0.45,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildLayerImage(_selectedBottom!.imagePath,
                                    height: mannequinHeight * 0.40),
                              ),
                            )
                                .animate(key: ValueKey(_selectedBottom!.id))
                                .slideY(begin: 0.1, end: 0)
                                .fade(),
                          ),

                        // Layer 4: Tops
                        if (_selectedTop != null && _selectedTop!.imagePath.isNotEmpty)
                          Positioned(
                            top: mannequinHeight * 0.22,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildLayerImage(_selectedTop!.imagePath,
                                    height: mannequinHeight * 0.35),
                              ),
                            )
                                .animate(key: ValueKey(_selectedTop!.id))
                                .slideY(begin: -0.1, end: 0)
                                .fade(),
                          ),

                        // Layer 5: Hair
                        if (_selectedHair != null)
                          Positioned(
                            top: _selectedHair!.offsetY,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Transform.scale(
                                      scale: _selectedHair!.scale,
                                      child: Image.asset(_selectedHair!.imagePath,
                                          width: 100))
                                  .animate(key: ValueKey(_selectedHair!.id))
                                  .fade(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ----------------------------------------------------
          // 2. Swipe Carousels (Shelves)
          // ----------------------------------------------------
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5))
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShelfCarousel(
                      title: "Hairstyles",
                      items: _hairstyles,
                      selectedItem: _selectedHair,
                      onItemSelected: (item) => setState(
                          () => _selectedHair = item as fashion.Hairstyle),
                      isAsset: true,
                    ),
                    _ShelfCarousel(
                      title: "Tops",
                      items: tops,
                      selectedItem: _selectedTop,
                      onItemSelected: (item) => setState(
                          () => _selectedTop = item as fashion.ClothingItem),
                    ),
                    _ShelfCarousel(
                      title: "Bottoms",
                      items: bottoms,
                      selectedItem: _selectedBottom,
                      onItemSelected: (item) => setState(
                          () => _selectedBottom = item as fashion.ClothingItem),
                    ),
                    _ShelfCarousel(
                      title: "Shoes",
                      items: shoes,
                      selectedItem: _selectedShoes,
                      onItemSelected: (item) => setState(
                          () => _selectedShoes = item as fashion.ClothingItem),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerImage(String path, {required double height}) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: const Icon(Icons.checkroom_rounded, color: AppTheme.textHint),
        ),
      );
    }
    return Image.asset(
      path,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        height: height,
        child: const Icon(Icons.checkroom_rounded, color: AppTheme.textHint),
      ),
    );
  }
}

class _ShelfCarousel extends StatelessWidget {
  final String title;
  final List<dynamic> items; // Accepts ClothingItem or Hairstyle
  final dynamic selectedItem;
  final Function(dynamic) onItemSelected;
  final bool isAsset;

  const _ShelfCarousel({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.isAsset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 4, top: 12),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary)),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItem == item;
              final imagePath = isAsset
                  ? item.imagePath
                  : (item as fashion.ClothingItem).imagePath;

              return GestureDetector(
                onTap: () => onItemSelected(item),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: AppTheme.primary, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: isAsset
                            ? Image.asset(imagePath,
                                fit: BoxFit.contain)
                            : _buildShelfImage(imagePath),
                      ),
                    ),
                    const SizedBox(height: 12), // Space above shelf
                  ],
                ),
              );
            },
          ),
        ),
        // Visual Shelf Plank
        Container(
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0D8),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2))
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildShelfImage(String path) {
    if (path.isEmpty) {
      return const Center(
        child: Icon(Icons.checkroom_rounded, color: AppTheme.textHint, size: 28),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.checkroom_rounded, color: AppTheme.textHint, size: 28),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.checkroom_rounded, color: AppTheme.textHint, size: 28),
      ),
    );
  }
}
