import 'package:epub_view/epub_view.dart';

part 'reader_mode.g.dart';

@HiveType(typeId: 7)
enum ReaderModeEnumType {
  @HiveField(0)
  horizontal,

  @HiveField(1)
  vertical,
}

ReaderModeEnumType? readerModeEnumTypeFromString(String name) {
  return ReaderModeEnumType.values
      .firstWhere((element) => element.name == name);
}

extension ReaderModeEnumTypeX on ReaderModeEnumType {}
