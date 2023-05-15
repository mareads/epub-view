// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReaderModeEnumTypeAdapter extends TypeAdapter<ReaderModeEnumType> {
  @override
  final int typeId = 7;

  @override
  ReaderModeEnumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReaderModeEnumType.horizontal;
      case 1:
        return ReaderModeEnumType.vertical;
      default:
        return ReaderModeEnumType.horizontal;
    }
  }

  @override
  void write(BinaryWriter writer, ReaderModeEnumType obj) {
    switch (obj) {
      case ReaderModeEnumType.horizontal:
        writer.writeByte(0);
        break;
      case ReaderModeEnumType.vertical:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderModeEnumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
