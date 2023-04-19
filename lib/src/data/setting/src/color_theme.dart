import 'package:flutter/material.dart';

class ColorTheme {
  static ColorTheme lightColorTheme = ColorTheme(
    backgroundColor: const Color(0xffffffff),
    buttonBackgroundColor: const Color(0xffffffff).withOpacity(.6),
    brightnessBackgroundColor: const Color(0xfff4f4f7),
    textColor: const Color(0xff0c1135),
    borderColor: const Color(0xffeeeeee),
    dividerColor: const Color(0xffeeeeee),
  );
  static ColorTheme sepiaColorTheme = ColorTheme(
    backgroundColor: const Color(0xfff8f6f0),
    buttonBackgroundColor: const Color(0xffffffff).withOpacity(.6),
    brightnessBackgroundColor: const Color(0xffe4dccf),
    textColor: const Color(0xff0c1135),
    borderColor: const Color(0xffe0d7c9),
    dividerColor: const Color(0xffeeeeee),
  );
  static ColorTheme nightWhileColorTheme = const ColorTheme(
    backgroundColor: Color(0xFF222222),
    buttonBackgroundColor: Color(0xffffffff),
    brightnessBackgroundColor: Color(0xff9096b8),
    textColor: Color(0xffffffff),
    borderColor: Color(0xff858baf),
    dividerColor: Color(0xff343434),
  );
  static ColorTheme nightGreyColorTheme = const ColorTheme(
    backgroundColor: Color(0xFF191919),
    buttonBackgroundColor: Color(0xff22284a),
    brightnessBackgroundColor: Color(0xff000000),
    textColor: Color(0xff767676),
    borderColor: Color(0xff767676),
    dividerColor: Color(0xff393939),
  );

  static List<ColorTheme> values = [
    lightColorTheme,
    sepiaColorTheme,
    nightWhileColorTheme,
    nightGreyColorTheme,
  ];

  final Color backgroundColor;
  final Color buttonBackgroundColor;
  final Color brightnessBackgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color dividerColor;

  const ColorTheme({
    required this.backgroundColor,
    required this.buttonBackgroundColor,
    required this.brightnessBackgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.dividerColor,
  });

  @override
  String toString() =>
      'ColorTheme{backgroundColor: $backgroundColor, buttonBackgroundColor: $buttonBackgroundColor, brightnessBackgroundColor: $brightnessBackgroundColor, textColor: $textColor, borderColor: $borderColor, dividerColor: $dividerColor}';
}
