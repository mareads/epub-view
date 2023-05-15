import 'package:epub_view/epub_view.dart';

part 'font_family.g.dart';

@HiveType(typeId: 3)
enum FontFamilyEnumType {
  @HiveField(0)
  notoSerif,

  @HiveField(1)
  trirong,

  @HiveField(2)
  sarabun,

  @HiveField(3)
  jsJindara,

  @HiveField(4)
  jamjuree,
}

FontFamilyEnumType? fontFamilyEnumTypeFromString(String name) {
  return FontFamilyEnumType.values
      .firstWhere((element) => element.name == name);
}
