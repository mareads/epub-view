import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigator_button.dart';

class EpubAppBar extends StatelessWidget {
  final Function handleOnDisposeReader;
  const EpubAppBar(
      {Key? key, required this.animation, required this.handleOnDisposeReader})
      : super(key: key);

  final Animation<double> animation;

  static GlobalKey themeSettingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      buildWhen: (prev, cur) =>
          prev.themeMode != cur.themeMode || prev.isShowToc != cur.isShowToc,
      builder: (_, state) {
        return Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            ignoring: !state.isShowToc,
            child: FadeTransition(
              opacity: animation,
              child: SizedBox(
                height: kToolbarHeight,
                child: AppBar(
                  backgroundColor: state.themeMode.data.backgroundColor,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  leadingWidth: 0,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppNavigatorButton.asset(
                        icon: "assets/images/back_icon@3x.png",
                        iconSize: const Size.fromHeight(24),
                        alignment: Alignment.center,
                        onTap: () async {
                          await handleOnDisposeReader();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          context
                              .read<ReaderSettingCubit>()
                              .onToggleChapterSection();
                        },
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        child: Container(
                          width: 128,
                          height: 40,
                          decoration: BoxDecoration(
                            color: state.themeMode.isLightMode ||
                                    state.themeMode.isSepiaMode
                                ? const Color(0xFFF4F4F7)
                                : const Color(0xff343434),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: BlocBuilder<ReaderSettingCubit,
                              ReaderSettingState>(builder: (context, state) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/menu_chapter.svg",
                                  color: state.isShowChaptersSection
                                      ? Theme.of(context).colorScheme.primary
                                      : state.themeMode.data.textColor,
                                  package: "epub_view",
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "เลือกตอน",
                                  style: GoogleFonts.sarabun(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: state.isShowChaptersSection
                                        ? Theme.of(context).colorScheme.primary
                                        : state.themeMode.data.textColor,
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          key: themeSettingKey,
                          onTap: () {
                            context
                                .read<ReaderSettingCubit>()
                                .onToggleSettingSection();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: state.themeMode.isLightMode ||
                                      state.themeMode.isSepiaMode
                                  ? const Color(0xFFF4F4F7)
                                  : const Color(0xff343434),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              state.isShowSettingSection
                                  ? 'assets/images/theme_setting_blue@3x.png'
                                  : 'assets/images/theme_setting_black@3x.png',
                              height: 24,
                              color: state.isShowSettingSection
                                  ? Theme.of(context).colorScheme.primary
                                  : state.themeMode.data.textColor,
                              package: "epub_view",
                            ),
                          ),
                        ),
                        const SizedBox(width: 20)
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
