import 'dart:async';

import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigator_button.dart';

class EpubToolbar extends StatelessWidget {
  const EpubToolbar({
    Key? key,
    required this.animation,
    required this.onPrevious,
    required this.onNext,
    required this.pageNumberController,
  }) : super(key: key);

  final Animation<double> animation;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final StreamController<int> pageNumberController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      bloc: context.read<ReaderSettingCubit>(),
      builder: (_, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: animation,
            child: Container(
              height: kToolbarHeight,
              color: state.themeMode.isLightMode || state.themeMode.isSepiaMode
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xff262626),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // child: _firstRow(context),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppNavigatorButton.asset(
                    icon: state.themeMode.isDarkenedMode
                        ? "assets/icons/navigation/back_grey_icon@3x.png"
                        : "assets/icons/navigation/back_icon.svg",
                    decoration: BoxDecoration(
                      color: state.themeMode.isDarkenedMode ? const Color(0xFF3b3b3b) : null,
                      border: state.themeMode.isDarkenedMode
                          ? Border.all(color: Colors.transparent)
                          : null,
                    ),
                    onTap: onPrevious,
                  ),
                  StreamBuilder<int>(
                      initialData: 1,
                      stream: pageNumberController.stream,
                      builder: (_, snapshot) {
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "${snapshot.data ?? 1}/30",
                                  style: GoogleFonts.sarabun(
                                    color: state.themeMode.isDarkenedMode
                                        ? const Color(0xff818181)
                                        : const Color(0xffffffff),
                                    fontSize: 14,
                                  )),
                              Container(
                                decoration: BoxDecoration(
                                  color: state.themeMode.isDarkenedMode
                                      ? const Color(0xff434343)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: (snapshot.data ?? 1) / 30,
                                    backgroundColor: state.themeMode.isDarkenedMode
                                        ? const Color(0xff434343)
                                        : const Color(0xFFf5f5f8),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  AppNavigatorButton.asset(
                    icon: state.themeMode.isDarkenedMode
                        ? "assets/icons/navigation/next_grey_icon@3x.png"
                        : "assets/icons/navigation/next_icon.svg",
                    decoration: BoxDecoration(
                      color: state.themeMode.isDarkenedMode ? const Color(0xFF3b3b3b) : null,
                      border: state.themeMode.isDarkenedMode
                          ? Border.all(color: Colors.transparent)
                          : null,
                    ),
                    onTap: onNext,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
