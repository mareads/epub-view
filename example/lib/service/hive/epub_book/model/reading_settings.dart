import 'package:epub_view/epub_view.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/font_family.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/font_size.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/line_height.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/reader_mode.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/theme_mode.dart';

part 'reading_settings.g.dart';

@HiveType(typeId: 1)
class ReadingSettingsType extends HiveObject with EquatableMixin {
  @HiveField(0)
  final FontFamilyEnumType? fontFamily;

  @HiveField(1)
  final FontSizeEnumType? fontSize;

  @HiveField(2)
  final LineHeightEnumType? lineHeight;

  @HiveField(3)
  final ReaderModeEnumType? readerMode;

  @HiveField(4)
  final ThemeModeEnumType? themeMode;

  ReadingSettingsType({
    this.fontFamily,
    this.fontSize,
    this.lineHeight,
    this.readerMode,
    this.themeMode,
  });

  ReadingSettingsType copyWith({
    FontFamilyEnumType? fontFamily,
    FontSizeEnumType? fontSize,
    LineHeightEnumType? lineHeight,
    ReaderModeEnumType? readerMode,
    ThemeModeEnumType? themeMode,
  }) {
    return ReadingSettingsType(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      readerMode: readerMode ?? this.readerMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory ReadingSettingsType.fromJson(Map<String, dynamic> json) {
    return ReadingSettingsType(
      fontFamily: FontFamilyEnumType.values
          .firstWhere((element) => element.name == json["fontFamily"]),
      fontSize: FontSizeEnumType.values
          .firstWhere((element) => element.name == json["fontSize"]),
      lineHeight: LineHeightEnumType.values
          .firstWhere((element) => element.name == json["lineHeight"]),
      readerMode: ReaderModeEnumType.values
          .firstWhere((element) => element.name == json["readerMode"]),
      themeMode: ThemeModeEnumType.values
          .firstWhere((element) => element.name == json["themeMode"]),
    );
  }

  Map<String, dynamic> toJson() => {
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (fontSize != null) 'fontSize': fontSize,
        if (lineHeight != null) 'lineHeight': lineHeight,
        if (readerMode != null) 'readerMode': readerMode,
        if (themeMode != null) 'themeMode': themeMode
      };

  @override
  List<Object?> get props =>
      [fontFamily, fontSize, lineHeight, readerMode, themeMode];
}
