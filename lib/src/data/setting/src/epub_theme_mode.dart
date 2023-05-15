import 'package:epub_view/src/data/setting/src/color_theme.dart';

enum EpubThemeMode { light, sepia, dark, darkened }

extension ExtensionEpubThemeMode on EpubThemeMode {
  bool get isLightMode => this == EpubThemeMode.light;

  bool get isSepiaMode => this == EpubThemeMode.sepia;

  bool get isDarkMode => this == EpubThemeMode.dark;

  bool get isDarkenedMode => this == EpubThemeMode.darkened;

  ColorTheme get data {
    switch (this) {
      case EpubThemeMode.light:
        return ColorTheme.lightColorTheme;
      case EpubThemeMode.sepia:
        return ColorTheme.sepiaColorTheme;
      case EpubThemeMode.dark:
        return ColorTheme.nightWhileColorTheme;
      case EpubThemeMode.darkened:
        return ColorTheme.nightGreyColorTheme;
      default:
        return ColorTheme.lightColorTheme;
    }
  }
}

EpubThemeMode? epubThemeModeFromString(String name) {
  return EpubThemeMode.values.firstWhere((element) => element.name == name);
}
