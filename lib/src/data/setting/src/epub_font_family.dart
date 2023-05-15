import 'package:google_fonts/google_fonts.dart';

enum EpubFontFamily {
  notoSerif("Noto Serif", "NotoSerif_regular"),
  trirong("Trirong", "Trirong_regular"),
  sarabun("Sarabun", "Sarabun_regular"),
  jsJindara("JS Jindara", "JsJindara"),
  jamjuree("Bai Jamjuree", "Bai_Jamjuree");

  final String shortName;
  final String family;

  const EpubFontFamily(this.shortName, this.family);
}

extension ExtensionFontFamily on EpubFontFamily {
  bool get isJsJindara => this == EpubFontFamily.jsJindara;
  bool get isSarabun => this == EpubFontFamily.sarabun;
  bool get isNotoSerif => this == EpubFontFamily.notoSerif;
  bool get isTrirong => this == EpubFontFamily.trirong;
  bool get isJsJamjuree => this == EpubFontFamily.jamjuree;

  String? get data {
    switch (this) {
      case EpubFontFamily.jsJindara:
        return "JsJindara";
      case EpubFontFamily.sarabun:
        return GoogleFonts.sarabun().fontFamily;
      case EpubFontFamily.notoSerif:
        return GoogleFonts.notoSerif().fontFamily;
      case EpubFontFamily.trirong:
        return GoogleFonts.trirong().fontFamily;
      case EpubFontFamily.jamjuree:
        return GoogleFonts.baiJamjuree().fontFamily;
      default:
        return GoogleFonts.sarabun().fontFamily;
    }
  }
}

EpubFontFamily? epubFontFamilyFromString(String name) {
  return EpubFontFamily.values.firstWhere((element) => element.name == name);
}
