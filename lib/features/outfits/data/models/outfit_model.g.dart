// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutfitModelAdapter extends TypeAdapter<OutfitModel> {
  @override
  final int typeId = 1;

  @override
  OutfitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutfitModel(
      id: fields[0] as String,
      clothingItemIds: (fields[1] as List).cast<String>(),
      date: fields[2] as DateTime,
      occasion: fields[3] as String,
      name: fields[4] as String,
      isSaved: fields[5] as bool,
      rating: fields[6] as int,
      notes: fields[7] as String,
      isAIGenerated: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OutfitModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clothingItemIds)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.occasion)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.isSaved)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.isAIGenerated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutfitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
