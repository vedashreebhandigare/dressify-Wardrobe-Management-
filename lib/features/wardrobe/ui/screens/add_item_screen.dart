import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/wardrobe/data/models/clothing_item.dart';
import '../../../../shared/providers/wardrobe_providers.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  String _category = 'Tops';
  String _color = 'White';
  String _season = 'All Season';
  String _occasion = 'Casual';
  String _pattern = 'Solid';
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked != null) {
        setState(() => _imagePath = picked.path);
        _autoDetectAttributes();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _autoDetectAttributes() {
    // Simulated AI detection
    final possibleCategories = ['Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Shoes'];
    final possibleColors = ['White', 'Black', 'Blue', 'Navy', 'Gray', 'Beige'];
    setState(() {
      _category = possibleCategories[DateTime.now().millisecond % possibleCategories.length];
      _color = possibleColors[DateTime.now().millisecond % possibleColors.length];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('AI detected: $_category, $_color'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final item = ClothingItem(
      imagePath: _imagePath ?? '',
      category: _category,
      color: _color,
      brand: _brandController.text,
      season: _season,
      pattern: _pattern,
      occasion: _occasion,
      notes: _notesController.text,
      name: _nameController.text,
      colorHex: _colorToHex(_color),
    );

    await ref.read(wardrobeListProvider.notifier).addItem(item);
    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item added to wardrobe! 🎉'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _colorToHex(String colorName) {
    const map = {
      'White': '#FFFFFF', 'Black': '#1A1A1A', 'Gray': '#808080',
      'Navy': '#001F5B', 'Blue': '#2196F3', 'Red': '#F44336',
      'Pink': '#E91E63', 'Orange': '#FF9800', 'Yellow': '#FFC107',
      'Green': '#4CAF50', 'Purple': '#9C27B0', 'Brown': '#795548',
      'Beige': '#F5F5DC', 'Multicolor': '#FF6B6B',
    };
    return map[colorName] ?? '#CCCCCC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              _ImagePickerSection(
                imagePath: _imagePath,
                isLoading: _isLoading,
                onCameraTap: () => _pickImage(ImageSource.camera),
                onGalleryTap: () => _pickImage(ImageSource.gallery),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // AI Badge
              if (_imagePath != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'AI has auto-detected attributes below. Review and edit as needed.',
                          style: TextStyle(fontSize: 13, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              _SectionTitle('Basic Info'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Item Name (e.g. Blue Linen Shirt)',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
              ),

              const SizedBox(height: 12),

              _DropdownField(
                label: 'Category',
                value: _category,
                items: AppConstants.categories.where((c) => c != 'All').toList(),
                onChanged: (v) => setState(() => _category = v!),
                icon: Icons.category_rounded,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  hintText: 'Brand (optional)',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),

              const SizedBox(height: 20),
              _SectionTitle('Details'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: 'Color',
                      value: _color,
                      items: AppConstants.colors,
                      onChanged: (v) => setState(() => _color = v!),
                      icon: Icons.palette_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      label: 'Pattern',
                      value: _pattern,
                      items: AppConstants.patterns,
                      onChanged: (v) => setState(() => _pattern = v!),
                      icon: Icons.texture_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: 'Season',
                      value: _season,
                      items: AppConstants.seasons,
                      onChanged: (v) => setState(() => _season = v!),
                      icon: Icons.thermostat_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      label: 'Occasion',
                      value: _occasion,
                      items: AppConstants.occasions,
                      onChanged: (v) => setState(() => _occasion = v!),
                      icon: Icons.event_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionTitle('Notes'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any notes about this item...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 42),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Add to Wardrobe'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _ImagePickerSection({
    required this.imagePath,
    required this.isLoading,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onGalleryTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : imagePath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_outlined, size: 64, color: AppTheme.textHint)),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded, size: 36, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text('Add Photo', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      const SizedBox(height: 4),
                      const Text('Tap to pick from gallery', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: onCameraTap,
                            icon: const Icon(Icons.camera_alt_rounded, size: 16),
                            label: const Text('Camera'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: onGalleryTap,
                            icon: const Icon(Icons.photo_library_rounded, size: 16),
                            label: const Text('Gallery'),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(14),
      menuMaxHeight: 300,
    );
  }
}
