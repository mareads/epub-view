// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_height.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LineHeightEnumTypeAdapter extends TypeAdapter<LineHeightEnumType> {
  @override
  final int typeId = 6;

  @override
  LineHeightEnumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LineHeightEnumType.light;
      case 1:
        return LineHeightEnumType.normal;
      case 2:
        return LineHeightEnumType.medium;
      case 3:
        return LineHeightEnumType.hard;
      case 4:
        return LineHeightEnumType.extra;
      default:
        return LineHeightEnumType.light;
    }
  }

  @override
  void write(BinaryWriter writer, LineHeightEnumType obj) {
    switch (obj) {
      case LineHeightEnumType.light:
        writer.writeByte(0);
        break;
      case LineHeightEnumType.normal:
        writer.writeByte(1);
        break;
      case LineHeightEnumType.medium:
        writer.writeByte(2);
        break;
      case LineHeightEnumType.hard:
        writer.writeByte(3);
        break;
      case LineHeightEnumType.extra:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineHeightEnumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
