// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingSettingsTypeAdapter extends TypeAdapter<ReadingSettingsType> {
  @override
  final int typeId = 1;

  @override
  ReadingSettingsType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingSettingsType(
      fontFamily: fields[0] as dynamic,
      fontSize: fields[1] as dynamic,
      lineHeight: fields[2] as dynamic,
      readerMode: fields[3] as dynamic,
      themeMode: fields[4] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingSettingsType obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fontFamily)
      ..writeByte(1)
      ..write(obj.fontSize)
      ..writeByte(2)
      ..write(obj.lineHeight)
      ..writeByte(3)
      ..write(obj.readerMode)
      ..writeByte(4)
      ..write(obj.themeMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSettingsTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
