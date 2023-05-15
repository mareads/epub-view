// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeModeEnumTypeAdapter extends TypeAdapter<ThemeModeEnumType> {
  @override
  final int typeId = 8;

  @override
  ThemeModeEnumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeModeEnumType.light;
      case 1:
        return ThemeModeEnumType.sepia;
      case 2:
        return ThemeModeEnumType.dark;
      case 3:
        return ThemeModeEnumType.darkened;
      default:
        return ThemeModeEnumType.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeModeEnumType obj) {
    switch (obj) {
      case ThemeModeEnumType.light:
        writer.writeByte(0);
        break;
      case ThemeModeEnumType.sepia:
        writer.writeByte(1);
        break;
      case ThemeModeEnumType.dark:
        writer.writeByte(2);
        break;
      case ThemeModeEnumType.darkened:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeEnumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
