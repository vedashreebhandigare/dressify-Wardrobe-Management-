// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothingItemAdapter extends TypeAdapter<ClothingItem> {
  @override
  final int typeId = 0;

  @override
  ClothingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothingItem(
      id: fields[0] as String?,
      imagePath: fields[1] as String,
      category: fields[2] as String,
      color: fields[3] as String,
      brand: fields[4] as String,
      season: fields[5] as String,
      wearCount: fields[6] as int,
      lastWornDate: fields[7] as DateTime?,
      isFavorite: fields[8] as bool,
      pattern: fields[9] as String,
      occasion: fields[10] as String,
      notes: fields[11] as String,
      createdAt: fields[12] as DateTime?,
      colorHex: fields[13] as String,
      name: fields[14] as String,
      mannequinLayerImage: fields[15] as String,
      layerType: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItem obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.season)
      ..writeByte(6)
      ..write(obj.wearCount)
      ..writeByte(7)
      ..write(obj.lastWornDate)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.pattern)
      ..writeByte(10)
      ..write(obj.occasion)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.colorHex)
      ..writeByte(14)
      ..write(obj.name)
      ..writeByte(15)
      ..write(obj.mannequinLayerImage)
      ..writeByte(16)
      ..write(obj.layerType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
