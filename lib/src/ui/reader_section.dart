import 'package:epub_view/src/data/models/chapter_paragraphs.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/data/setting/src/reader_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../epub_view.dart';
import '../models/paragraph_progress.dart';
import '../providers/cubits/reader_setting_cubit.dart';

class ReaderSection extends StatefulWidget {
  final EpubViewBuilders builders;
  final ChapterParagraphs? currentChapter;
  final EpubController controller;
  final Exception? loadingError;
  final ChapterParagraphs? chapterData;
  final Widget Function(BuildContext context, ChapterParagraphs chapterData)
      buildLoaded;
  final Widget Function(BuildContext context, ChapterParagraphs chapterData)
      buildLoadedHorizontal;
  const ReaderSection(
      {Key? key,
      required this.builders,
      required this.buildLoaded,
      required this.buildLoadedHorizontal,
      required this.loadingError,
      required this.controller,
      required this.chapterData,
      this.currentChapter})
      : super(key: key);

  @override
  State<ReaderSection> createState() => _ReaderSectionState();
}

class _ReaderSectionState extends State<ReaderSection> {
  final List<ParagraphProgress> paragraphProgressList = [];

  _scrollListener() {
    final currentParagraph =
        context.read<ReaderSettingCubit>().state.readerMode.isVertical
            ? widget.controller.currentValueListenable.value!
                    .currentAllParagraphIndex +
                1
            : widget.controller.currentValueListenable.value!.paragraphNumber;

    // print("widget.currentChapter?.paragraphs.length.toDouble()");
    // print(widget.currentChapter?.paragraphs.length.toDouble());
    // print("currentParagraph");
    // print(currentParagraph);
    context.read<ReaderSettingCubit>().onScrollUpdate(UserScrollNotification(
        metrics: FixedScrollMetrics(
          maxScrollExtent: widget.currentChapter?.paragraphs.length.toDouble(),
          pixels: currentParagraph.toDouble(),
          minScrollExtent: 1,
          viewportDimension: 1,
          axisDirection: AxisDirection.right,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
        ),
        context: context,
        direction: ScrollDirection.idle));
  }

  @override
  void initState() {
    super.initState();

    widget.controller.currentValueListenable.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.controller.currentValueListenable.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      buildWhen: (prev, cur) =>
          prev.themeMode != cur.themeMode || prev.readerMode != cur.readerMode,
      builder: (ctx, state) {
        return GestureDetector(
            onTap: () {
              ctx.read<ReaderSettingCubit>().onToggleAppBar();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  top: 0,
                  child: widget.currentChapter != null
                      ? ColoredBox(
                          color: state.themeMode.data.backgroundColor,
                          child: widget.builders.builder(
                              context,
                              widget.builders,
                              widget.controller.loadingState.value,
                              state.readerMode.isHorizontal
                                  ? widget.buildLoadedHorizontal
                                  : widget.buildLoaded,
                              widget.loadingError,
                              widget.chapterData!),
                        )
                      : const Text("Loading..."),
                ),
                // if (isShowToc || isShowThemeSetting)
                //   InkWell(
                //     onTap: isShowToc ? _toggleToc : _toggleThemeSetting,
                //     child: Container(
                //       height: MediaQuery.of(context).size.height,
                //       width: MediaQuery.of(context).size.width,
                //       color: Colors.black.withOpacity(.3),
                //     ),
                //   )
              ],
            ));
      },
    );
  }
}
