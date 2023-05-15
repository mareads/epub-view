import 'package:epub_view/epub_view.dart';

part 'font_size.g.dart';

@HiveType(typeId: 5)
enum FontSizeEnumType {
  @HiveField(0)
  superLight,

  @HiveField(1)
  light,

  @HiveField(2)
  normal,

  @HiveField(3)
  medium,

  @HiveField(4)
  hard,

  @HiveField(5)
  extra,
}

FontSizeEnumType? fontSizeEnumTypeFromString(String name) {
  return FontSizeEnumType.values.firstWhere((element) => element.name == name);
}
