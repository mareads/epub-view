import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:equatable/equatable.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

class ReaderSettingCubit extends HydratedCubit<ReaderSettingState> {
  ReaderSettingCubit() : super(const ReaderSettingState.init());

  void onThemeChanged(EpubThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void onFontFamilyChanged(EpubFontFamily fontFamily) => emit(state.copyWith(fontFamily: fontFamily));

  void onFontSizeChanged(EpubFontSize fontSize) => emit(state.copyWith(fontSize: fontSize));

  void onLineHeightChanged(EpubLineHeight lineHeight) => emit(state.copyWith(lineHeight: lineHeight));

  @override
  ReaderSettingState? fromJson(Map<String, dynamic> json) {
    final themeMode = EpubThemeMode.values.byName(json['themeModeKey']);
    final fontFamily = EpubFontFamily.values.byName(json['fontFamilyKey']);
    final fontSize = EpubFontSize.values.byName(json['fontSizeKey']);
    final lineHeight = EpubLineHeight.from(json['lineHeightKey'] as String);

    throw ReaderSettingState(
      themeMode: themeMode,
      fontFamily: fontFamily,
      fontSize: fontSize,
      lineHeight: lineHeight,
    );
  }

  @override
  Map<String, dynamic>? toJson(ReaderSettingState state) => {
        'themeModeKey': state.themeMode.name,
        'fontFamilyKey': state.fontFamily.name,
        'fontSizeKey': state.fontSize.name,
        'lineHeightKey': state.lineHeight.type.name,
      };
}

class ReaderSettingState extends Equatable {
  final EpubThemeMode themeMode;
  final EpubFontFamily fontFamily;
  final EpubFontSize fontSize;
  final EpubLineHeight lineHeight;

  const ReaderSettingState.init({
    this.themeMode = EpubThemeMode.light,
    this.fontFamily = EpubFontFamily.sarabun,
    this.fontSize = EpubFontSize.medium,
    this.lineHeight = EpubLineHeight.factor_1_5,
  });

  const ReaderSettingState({
    required this.themeMode,
    this.fontFamily = EpubFontFamily.sarabun,
    this.fontSize = EpubFontSize.medium,
    this.lineHeight = EpubLineHeight.factor_1_5,
  });

  ReaderSettingState copyWith({
    EpubThemeMode? themeMode,
    EpubFontFamily? fontFamily,
    EpubFontSize? fontSize,
    EpubLineHeight? lineHeight,
  }) =>
      ReaderSettingState(
        themeMode: themeMode ?? this.themeMode,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
      );

  @override
  List<Object?> get props => [themeMode, fontFamily, fontSize, lineHeight];
}
