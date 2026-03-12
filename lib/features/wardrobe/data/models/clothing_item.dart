import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'clothing_item.g.dart';

@HiveType(typeId: 0)
class ClothingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String category;

  @HiveField(3)
  String color;

  @HiveField(4)
  String brand;

  @HiveField(5)
  String season;

  @HiveField(6)
  int wearCount;

  @HiveField(7)
  DateTime? lastWornDate;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  String pattern;

  @HiveField(10)
  String occasion;

  @HiveField(11)
  String notes;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  String colorHex;

  @HiveField(14)
  String name;

  ClothingItem({
    String? id,
    required this.imagePath,
    required this.category,
    required this.color,
    this.brand = '',
    required this.season,
    this.wearCount = 0,
    this.lastWornDate,
    this.isFavorite = false,
    this.pattern = 'Solid',
    this.occasion = 'Casual',
    this.notes = '',
    DateTime? createdAt,
    this.colorHex = '#FFFFFF',
    this.name = '',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ClothingItem copyWith({
    String? imagePath,
    String? category,
    String? color,
    String? brand,
    String? season,
    int? wearCount,
    DateTime? lastWornDate,
    bool? isFavorite,
    String? pattern,
    String? occasion,
    String? notes,
    String? colorHex,
    String? name,
  }) {
    return ClothingItem(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      season: season ?? this.season,
      wearCount: wearCount ?? this.wearCount,
      lastWornDate: lastWornDate ?? this.lastWornDate,
      isFavorite: isFavorite ?? this.isFavorite,
      pattern: pattern ?? this.pattern,
      occasion: occasion ?? this.occasion,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      colorHex: colorHex ?? this.colorHex,
      name: name ?? this.name,
    );
  }

  bool get isUnused {
    if (lastWornDate == null) return createdAt.isBefore(DateTime.now().subtract(const Duration(days: 90)));
    return lastWornDate!.isBefore(DateTime.now().subtract(const Duration(days: 90)));
  }
}
