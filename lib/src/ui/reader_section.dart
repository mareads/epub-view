import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/data/setting/src/reader_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../epub_view.dart';
import '../providers/cubits/reader_setting_cubit.dart';

class ReaderSection extends StatelessWidget {
  final EpubViewBuilders builders;
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
      required this.controller})
      : super(key: key);

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
                      if (scroll is UserScrollNotification) {
                        ctx.read<ReaderSettingCubit>().onScrollUpdate(scroll);
                      }

                      return false;
                    },
                    child: ColoredBox(
                      color: state.themeMode.data.backgroundColor,
                      child: builders.builder(
                        context,
                        builders,
                        controller.loadingState.value,
                        state.readerMode.isHorizontal
                            ? buildLoadedHorizontal
                            : buildLoaded,
                        loadingError,
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
