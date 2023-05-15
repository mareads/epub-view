import 'dart:developer';

import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../data/setting/src/reader_mode.dart';

class ReaderSettingCubit extends Cubit<ReaderSettingState> {
  ReaderSettingCubit({ReadingSettings? initReadingSettings})
      : super(initReadingSettings != null
            ? ReaderSettingState.initFromReaderSettings(
                readingSetting: initReadingSettings)
            : const ReaderSettingState.init());

  void onThemeChanged(EpubThemeMode mode) =>
      emit(state.copyWith(themeMode: mode));

  void onScrollUpdate(ScrollNotification scrollNotification) =>
      emit(state.copyWith(scrollNotification: scrollNotification));

  void onFontFamilyChanged(EpubFontFamily fontFamily) =>
      emit(state.copyWith(fontFamily: fontFamily));

  void onToggleAppBar() {
    final isShowToc = !state.isShowToc;
    if (isShowToc) {
      emit(state.copyWith(isShowToc: !state.isShowToc));
    } else {
      emit(state.copyWith(
          isShowToc: !state.isShowToc,
          isShowSettingSection: !state.isShowToc,
          isShowChaptersSection: !state.isShowToc));
    }
  }

  void onToggleChapterSection() {
    emit(state.copyWith(
        isShowChaptersSection: !state.isShowChaptersSection,
        isShowSettingSection: false));
  }

  void onToggleSettingSection() {
    emit(state.copyWith(
        isShowSettingSection: !state.isShowSettingSection,
        isShowChaptersSection: false));
  }

  void onFontSizeChanged(EpubFontSize fontSize) =>
      emit(state.copyWith(fontSize: fontSize));

  void onLineHeightChanged(EpubLineHeight lineHeight) =>
      emit(state.copyWith(lineHeight: lineHeight));

  void onReaderModeChanged(ReaderMode readerMode) {
    emit(state.copyWith(readerMode: readerMode));
    if (state.scrollNotification != null) {
      onScrollUpdate(UserScrollNotification(
          direction: ScrollDirection.forward,
          metrics: state.scrollNotification!.metrics
              .copyWith(pixels: 0, maxScrollExtent: 100),
          context: state.scrollNotification!.context!));
    }
  }

  Color getBackgroundColor(
      {required BuildContext context, required bool isSelected}) {
    return state.themeMode.isDarkenedMode
        ? isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(.3)
            : state.themeMode.data.buttonBackgroundColor
        : state.themeMode.data.buttonBackgroundColor;
  }

  Color? getIconColor(
      {required BuildContext context, required bool isSelected}) {
    return isSelected
        ? state.themeMode.isDarkenedMode
            ? Theme.of(context).colorScheme.secondary
            : null
        : state.themeMode.isDarkMode
            ? const Color(0xff0c1135)
            : state.themeMode.data.textColor;
  }

  @override
  ReaderSettingState? fromJson(Map<String, dynamic> json) {
    final themeMode = EpubThemeMode.values.byName(json['themeModeKey']);
    final fontFamily = EpubFontFamily.values.byName(json['fontFamilyKey']);
    final fontSize = EpubFontSize.values.byName(json['fontSizeKey']);
    final lineHeight = EpubLineHeight.from(json['lineHeightKey'] as String);

    return ReaderSettingState(
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
  final bool isShowToc;
  final bool isShowSettingSection;
  final bool isShowChaptersSection;
  final ScrollNotification? scrollNotification;
  final EpubFontFamily fontFamily;
  final EpubFontSize fontSize;
  final EpubLineHeight lineHeight;
  final ReaderMode readerMode;

  const ReaderSettingState.init({
    this.themeMode = EpubThemeMode.light,
    this.isShowToc = true,
    this.isShowSettingSection = false,
    this.isShowChaptersSection = false,
    this.scrollNotification,
    this.fontFamily = EpubFontFamily.sarabun,
    this.fontSize = EpubFontSize.medium,
    this.readerMode = ReaderMode.vertical,
    this.lineHeight = EpubLineHeight.factor_1_5,
  });

  const ReaderSettingState({
    required this.themeMode,
    this.scrollNotification,
    this.isShowToc = true,
    this.isShowSettingSection = false,
    this.isShowChaptersSection = false,
    this.fontFamily = EpubFontFamily.sarabun,
    this.fontSize = EpubFontSize.medium,
    this.readerMode = ReaderMode.vertical,
    this.lineHeight = EpubLineHeight.factor_1_5,
  });

  num get scrollProgressRatio {
    return scrollNotification != null
        ? scrollNotification!.metrics.pixels /
            scrollNotification!.metrics.maxScrollExtent
        : 0;
  }

  static initFromReaderSettings({required ReadingSettings readingSetting}) {
    return ReaderSettingState(
        themeMode: readingSetting.themeMode ?? EpubThemeMode.light,
        isShowToc: true,
        isShowSettingSection: false,
        isShowChaptersSection: false,
        fontFamily: readingSetting.fontFamily ?? EpubFontFamily.sarabun,
        fontSize: readingSetting.fontSize ?? EpubFontSize.normal,
        readerMode: readingSetting.readerMode ?? ReaderMode.horizontal,
        lineHeight: readingSetting.lineHeight ?? EpubLineHeight.factor_1_5);
  }

  num get scrollProgressPercentage {
    return (scrollProgressRatio * 100).ceil().toInt();
  }

  ReaderSettingState copyWith({
    EpubThemeMode? themeMode,
    EpubFontFamily? fontFamily,
    EpubFontSize? fontSize,
    EpubLineHeight? lineHeight,
    ScrollNotification? scrollNotification,
    ReaderMode? readerMode,
    bool? isShowToc,
    bool? isShowChaptersSection,
    bool? isShowSettingSection,
  }) {
    return ReaderSettingState(
      themeMode: themeMode ?? this.themeMode,
      isShowToc: isShowToc ?? this.isShowToc,
      isShowChaptersSection:
          isShowChaptersSection ?? this.isShowChaptersSection,
      isShowSettingSection: isShowSettingSection ?? this.isShowSettingSection,
      readerMode: readerMode ?? this.readerMode,
      scrollNotification: scrollNotification ?? this.scrollNotification,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        fontFamily,
        fontSize,
        lineHeight,
        scrollNotification,
        readerMode,
        isShowToc,
        isShowChaptersSection,
        isShowSettingSection
      ];
}
