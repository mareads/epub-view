import 'package:epub_view/epub_view.dart';

part 'theme_mode.g.dart';

@HiveType(typeId: 8)
enum ThemeModeEnumType {
  @HiveField(0)
  light,

  @HiveField(1)
  sepia,

  @HiveField(2)
  dark,

  @HiveField(3)
  darkened,
}

ThemeModeEnumType? themeModeEnumTypeFromString(String name) {
  return ThemeModeEnumType.values.firstWhere((element) => element.name == name);
}
