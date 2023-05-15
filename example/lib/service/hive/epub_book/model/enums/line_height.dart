import 'package:epub_view/epub_view.dart';

part 'line_height.g.dart';

@HiveType(typeId: 6)
enum LineHeightEnumType {
  @HiveField(0)
  light,

  @HiveField(1)
  normal,

  @HiveField(2)
  medium,

  @HiveField(3)
  hard,

  @HiveField(4)
  extra,
}

LineHeightEnumType? lineHeightEnumTypeFromString(String name) {
  return LineHeightEnumType.values.firstWhere((element) => element.name == name);
}
