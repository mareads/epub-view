// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_size.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FontSizeEnumTypeAdapter extends TypeAdapter<FontSizeEnumType> {
  @override
  final int typeId = 5;

  @override
  FontSizeEnumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FontSizeEnumType.superLight;
      case 1:
        return FontSizeEnumType.light;
      case 2:
        return FontSizeEnumType.normal;
      case 3:
        return FontSizeEnumType.medium;
      case 4:
        return FontSizeEnumType.hard;
      case 5:
        return FontSizeEnumType.extra;
      default:
        return FontSizeEnumType.superLight;
    }
  }

  @override
  void write(BinaryWriter writer, FontSizeEnumType obj) {
    switch (obj) {
      case FontSizeEnumType.superLight:
        writer.writeByte(0);
        break;
      case FontSizeEnumType.light:
        writer.writeByte(1);
        break;
      case FontSizeEnumType.normal:
        writer.writeByte(2);
        break;
      case FontSizeEnumType.medium:
        writer.writeByte(3);
        break;
      case FontSizeEnumType.hard:
        writer.writeByte(4);
        break;
      case FontSizeEnumType.extra:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontSizeEnumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
