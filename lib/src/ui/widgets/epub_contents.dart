import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/data/setting/src/reader_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EpubViewContents extends StatelessWidget {
  const EpubViewContents({
    Key? key,
    required this.controller,
    required this.onSelectChapter,
    this.scrollController,
    this.contentHeight = 38,
    this.readerSettingState,
  }) : super(key: key);

  final void Function({required int chapterIndex, required BuildContext ctx}) onSelectChapter;
  final EpubController controller;
  final ScrollController? scrollController;
  final double contentHeight;
  final ReaderSettingState? readerSettingState;

  static final TextStyle _style = GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w300);

  ReaderSettingState get _readerSettingState =>
      readerSettingState ?? controller.readerSettingController.state;

  Color get backgroundColor =>
      _readerSettingState.themeMode.isLightMode || _readerSettingState.themeMode.isSepiaMode
          ? const Color(0xffffffff)
          : const Color(0xff262626);

  Color get trackColor =>
      _readerSettingState.themeMode.isLightMode || _readerSettingState.themeMode.isSepiaMode
          ? const Color(0xfff4f2ec)
          : const Color(0xff434343);

  Color get focusBackgroundColor {
    switch (_readerSettingState.themeMode.name) {
      case "light":
        return const Color(0xfff1f9ff);
      case "sepia":
        return const Color(0xfff2f0e9);
      case "dark":
        return const Color(0xff3b3b3b);
      case "darkened":
        return const Color(0xff262c55);
      default:
        return const Color(0xfff1f9ff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scroll = scrollController ?? ScrollController(debugLabel: "EpubViewContents");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final index = controller.tableOfContentsListenable.value.indexWhere(
      //     (element) =>
      //         element.title!.trim() ==
      //         (controller.currentValueListenable.value?.chapter?.Title
      //                 ?.replaceAll('\n', '')
      //                 .trim() ??
      //             ''));
      // scroll.jumpTo(index * contentHeight);
    });

    return ValueListenableBuilder<EpubChapterViewValue?>(
      valueListenable: controller.currentValueListenable,
      builder: (_, chapterData, childA) => ValueListenableBuilder<List<EpubViewChapter>>(
        valueListenable: controller.tableOfContentsListenable,
        builder: (__, data, childB) {
          Widget content;

          if (data.isNotEmpty) {
            content = Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  crossAxisMargin: Theme.of(context).scrollbarTheme.crossAxisMargin,
                  mainAxisMargin: 2,
                  thumbColor: _readerSettingState.themeMode.isDarkMode
                      ? const MaterialStatePropertyAll(Color(0xff858baf))
                      : Theme.of(context).scrollbarTheme.thumbColor,
                  trackColor: MaterialStateProperty.all(trackColor),
                  radius: Theme.of(context).scrollbarTheme.radius,
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                ),
              ),
              child: Scrollbar(
                controller: scroll,
                child: ListView.builder(
                  controller: scroll,
                  shrinkWrap: true,
                  key: Key('$runtimeType.content'),
                  itemBuilder: (___, index) {
                    int chapterNumber = chapterData?.chapterNumber ?? 0;
                    bool isFocus = chapterNumber == (index + 1);

                    final contentStyle = _style.copyWith(
                        color: isFocus
                            ? _readerSettingState.themeMode.isDarkMode
                                ? const Color(0xffffffff)
                                : const Color(0xff3f54d9)
                            : _readerSettingState.themeMode.isDarkMode
                                ? const Color(0xff858baf)
                                : _readerSettingState.themeMode.data.textColor);

                    return SizedBox(
                      height: contentHeight,
                      child: Material(
                        color: isFocus ? focusBackgroundColor : backgroundColor,
                        child: BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
                            builder: (context, state) {
                          return ListTile(
                            horizontalTitleGap: 0,
                            minVerticalPadding: 0,
                            visualDensity: const VisualDensity(vertical: -4),
                            leading: Text(
                              "${index + 1}.",
                              style: contentStyle,
                            ),
                            title: Text(
                              data[index].title!.trim(),
                              style: contentStyle,
                            ),
                            onTap: () async {
                              onSelectChapter(chapterIndex: index, ctx: context);
                              // if (state.readerMode.isHorizontal) {
                              //   chapterData?.onHorizontalPageChange(
                              //       chapterId: index);
                              // } else {
                              //   await controller.scrollTo(
                              //       index: data[index].startIndex);
                              //   double currentPositions =
                              //       (index * contentHeight) % 360;
                              //   if (currentPositions >= 290) {
                              //     scroll.jumpTo(index * contentHeight);
                              //   }
                              // }
                            },
                          );
                        }),
                      ),
                    );
                  },
                  itemCount: data.length,
                ),
              ),
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Stack(
              children: [
                InkWell(
                  onTap: () => context.read<ReaderSettingCubit>().onToggleChapterSection(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(.3),
                  ),
                ),
                Material(
                  elevation: 8.0,
                  textStyle: _style,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 50,
                      maxHeight: 390,
                    ),
                    decoration: BoxDecoration(color: backgroundColor),
                    padding: const EdgeInsets.all(4),
                    child: content,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
