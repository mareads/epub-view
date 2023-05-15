import '../data/setting/src/epub_font_family.dart';
import '../data/setting/src/epub_font_size.dart';
import '../data/setting/src/epub_line_height.dart';
import '../data/setting/src/epub_theme_mode.dart';
import '../data/setting/src/reader_mode.dart';

class ReadingSettings {
  final EpubThemeMode? themeMode;
  final EpubFontFamily? fontFamily;
  final EpubFontSize? fontSize;
  final EpubLineHeight? lineHeight;
  final ReaderMode? readerMode;
  const ReadingSettings({
    this.themeMode = EpubThemeMode.light,
    this.fontFamily = EpubFontFamily.sarabun,
    this.fontSize = EpubFontSize.medium,
    this.readerMode = ReaderMode.vertical,
    this.lineHeight = EpubLineHeight.factor_1_5,
  });
}
