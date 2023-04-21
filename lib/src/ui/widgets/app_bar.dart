import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigator_button.dart';

class EpubAppBar extends StatelessWidget {
  const EpubAppBar({
    Key? key,
    required this.isOpenToc,
    required this.isOpenThemeSetting,
    required this.animation,
    required this.onTapToc,
    required this.onTapThemeSetting,
  }) : super(key: key);

  final bool isOpenToc;
  final bool isOpenThemeSetting;
  final Animation<double> animation;
  final VoidCallback onTapToc;
  final VoidCallback onTapThemeSetting;

  static GlobalKey tocKey = GlobalKey();
  static GlobalKey themeSettingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      builder: (_, state) {
        return Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            ignoring: animation.value == 1,
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
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: onTapToc,
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        child: Container(
                          key: tocKey,
                          width: 128,
                          height: 40,
                          decoration: BoxDecoration(
                            color: state.themeMode.isLightMode ||
                                    state.themeMode.isSepiaMode
                                ? const Color(0xFFF4F4F7)
                                : const Color(0xff343434),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/menu_chapter.svg",
                                color: isOpenToc
                                    ? Theme.of(context).colorScheme.primary
                                    : state.themeMode.data.textColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "เลือกตอน",
                                style: GoogleFonts.sarabun(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: isOpenToc
                                      ? Theme.of(context).colorScheme.primary
                                      : state.themeMode.data.textColor,
                                ),
                              )
                            ],
                          ),
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
                          onTap: onTapThemeSetting,
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
                              isOpenThemeSetting
                                  ? 'assets/images/theme_setting_blue@3x.png'
                                  : 'assets/images/theme_setting_black@3x.png',
                              height: 24,
                              color: isOpenThemeSetting
                                  ? Theme.of(context).colorScheme.primary
                                  : state.themeMode.data.textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20)
                      ],
                    ),
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
