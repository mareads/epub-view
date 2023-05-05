import 'dart:developer';
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
  final List<ParagraphProgress> paragraphsProgressList;
  final EpubController controller;
  final Exception? loadingError;
  final Widget Function(BuildContext context) buildLoaded;
  final Widget Function(BuildContext context) buildLoadedHorizontal;
  const ReaderSection(
      {Key? key,
      required this.builders,
      required this.buildLoaded,
      required this.buildLoadedHorizontal,
      required this.loadingError,
      required this.controller,
      required this.paragraphsProgressList})
      : super(key: key);

  @override
  State<ReaderSection> createState() => _ReaderSectionState();
}

class _ReaderSectionState extends State<ReaderSection> {
  final List<ParagraphProgress> paragraphProgressList = [];

  @override
  void initState() {
    super.initState();

    widget.controller.currentValueListenable.addListener(() {
      if (context.read<ReaderSettingCubit>().state.readerMode.isVertical) {
        final currentChapter =
            widget.controller.currentValueListenable.value!.chapterNumber - 1;
        final currentParagraph =
            widget.controller.currentValueListenable.value!.paragraphNumber - 1;
        final currentProgress = widget.paragraphsProgressList.firstWhere(
            (element) =>
                element.chapterIndex == currentChapter &&
                element.paragraphIndex == currentParagraph);
        context
            .read<ReaderSettingCubit>()
            .onScrollUpdate(UserScrollNotification(
                metrics: FixedScrollMetrics(
                  maxScrollExtent:
                      widget.paragraphsProgressList.length.toDouble(),
                  pixels: currentProgress.paragraphProgressIndex.toDouble(),
                  minScrollExtent: 1,
                  viewportDimension: 1,
                  axisDirection: AxisDirection.right,
                ),
                context: context,
                direction: ScrollDirection.idle));
      }
    });
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
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (state.readerMode.isHorizontal) {
                        ctx.read<ReaderSettingCubit>().onScrollUpdate(scroll);
                      }

                      return false;
                    },
                    child: ColoredBox(
                      color: state.themeMode.data.backgroundColor,
                      child: widget.builders.builder(
                        context,
                        widget.builders,
                        widget.controller.loadingState.value,
                        state.readerMode.isHorizontal
                            ? widget.buildLoadedHorizontal
                            : widget.buildLoaded,
                        widget.loadingError,
                      ),
                    ),
                  ),
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
