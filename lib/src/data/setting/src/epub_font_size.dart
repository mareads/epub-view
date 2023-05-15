enum EpubFontSize { superLight, light, normal, medium, hard, extra }

extension ExtensionEpubFontSize on EpubFontSize {
  bool get isSuperLight => this == EpubFontSize.superLight;

  bool get isLight => this == EpubFontSize.light;

  bool get isNormal => this == EpubFontSize.normal;

  bool get isMedium => this == EpubFontSize.medium;

  bool get isHard => this == EpubFontSize.hard;

  bool get isExtra => this == EpubFontSize.extra;

  double get data {
    switch (this) {
      case EpubFontSize.superLight:
        return 14;
      case EpubFontSize.light:
        return 16;
      case EpubFontSize.normal:
        return 18;
      case EpubFontSize.medium:
        return 20;
      case EpubFontSize.hard:
        return 22;
      case EpubFontSize.extra:
        return 24;
      default:
        return 18;
    }
  }

  double get dataJs {
    // when use font JS Jindara that use this font size
    switch (this) {
      case EpubFontSize.superLight:
        return 20;
      case EpubFontSize.light:
        return 24;
      case EpubFontSize.normal:
        return 26;
      case EpubFontSize.medium:
        return 30;
      case EpubFontSize.hard:
        return 32;
      case EpubFontSize.extra:
        return 34;
      default:
        return 26;
    }
  }
}

EpubFontSize? epubFontSizeFromString(String name) {
  return EpubFontSize.values.firstWhere((element) => element.name == name);
}
