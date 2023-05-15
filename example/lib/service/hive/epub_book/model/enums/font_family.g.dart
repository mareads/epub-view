// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_family.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FontFamilyEnumTypeAdapter extends TypeAdapter<FontFamilyEnumType> {
  @override
  final int typeId = 3;

  @override
  FontFamilyEnumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FontFamilyEnumType.notoSerif;
      case 1:
        return FontFamilyEnumType.trirong;
      case 2:
        return FontFamilyEnumType.sarabun;
      case 3:
        return FontFamilyEnumType.jsJindara;
      case 4:
        return FontFamilyEnumType.jamjuree;
      default:
        return FontFamilyEnumType.notoSerif;
    }
  }

  @override
  void write(BinaryWriter writer, FontFamilyEnumType obj) {
    switch (obj) {
      case FontFamilyEnumType.notoSerif:
        writer.writeByte(0);
        break;
      case FontFamilyEnumType.trirong:
        writer.writeByte(1);
        break;
      case FontFamilyEnumType.sarabun:
        writer.writeByte(2);
        break;
      case FontFamilyEnumType.jsJindara:
        writer.writeByte(3);
        break;
      case FontFamilyEnumType.jamjuree:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontFamilyEnumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
