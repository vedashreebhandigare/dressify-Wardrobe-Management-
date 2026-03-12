import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'outfit_model.g.dart';

@HiveType(typeId: 1)
class OutfitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  List<String> clothingItemIds;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String occasion;

  @HiveField(4)
  String name;

  @HiveField(5)
  bool isSaved;

  @HiveField(6)
  int rating;

  @HiveField(7)
  String notes;

  @HiveField(8)
  bool isAIGenerated;

  OutfitModel({
    String? id,
    required this.clothingItemIds,
    DateTime? date,
    this.occasion = 'Casual',
    this.name = '',
    this.isSaved = false,
    this.rating = 0,
    this.notes = '',
    this.isAIGenerated = false,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  OutfitModel copyWith({
    List<String>? clothingItemIds,
    DateTime? date,
    String? occasion,
    String? name,
    bool? isSaved,
    int? rating,
    String? notes,
    bool? isAIGenerated,
  }) {
    return OutfitModel(
      id: id,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      date: date ?? this.date,
      occasion: occasion ?? this.occasion,
      name: name ?? this.name,
      isSaved: isSaved ?? this.isSaved,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
    );
  }
}
