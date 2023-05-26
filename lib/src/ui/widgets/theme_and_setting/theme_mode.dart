import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppThemeModeWidget extends StatelessWidget {
  const AppThemeModeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReaderSettingCubit>();

    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      bloc: provider,
      builder: (_, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("โหมดสว่าง/มืด"),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => rebuildTheme.call(EpubThemeMode.light, provider: provider),
                  child: Opacity(
                    opacity: state.themeMode.isLightMode ? 1 : .6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: state.themeMode.isLightMode
                              ? Theme.of(context).colorScheme.secondary
                              : state.themeMode.data.borderColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        "assets/images/light_mode@3x.png",
                        package: "epub_view",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => rebuildTheme.call(EpubThemeMode.sepia, provider: provider),
                  child: Opacity(
                    opacity: state.themeMode.isSepiaMode ? 1 : .6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: const Color(0xFFf0ede6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1,
                            color: state.themeMode.isSepiaMode
                                ? const Color(0xFF3f54d9).withOpacity(.7)
                                : const Color(0xFFf4f4f4),
                          )),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        "assets/images/sepia_mode@3x.png",
                        color: const Color(0xFF0c1135),
                        package: "epub_view",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => rebuildTheme.call(EpubThemeMode.dark, provider: provider),
                  child: Opacity(
                    opacity: state.themeMode.isDarkMode ? 1 : .6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: const Color(0xFF393c4e)
                              .withOpacity(state.themeMode.isDarkMode ? 1 : .6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1,
                            color: state.themeMode.isDarkMode
                                ? const Color(0xFF3f54d9).withOpacity(.7)
                                : const Color(0xFFEEEEEE),
                          )),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        "assets/images/dark_while_mode@3x.png",
                        package: "epub_view",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => rebuildTheme.call(EpubThemeMode.darkened, provider: provider),
                  child: Opacity(
                    opacity: state.themeMode.isDarkenedMode ? 1 : .6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: const Color(0xFF000000).withOpacity(.6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1,
                            color: state.themeMode.isDarkenedMode
                                ? const Color(0xFF3f54d9).withOpacity(.7)
                                : const Color(0xFFEEEEEE),
                          )),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        "assets/images/dark_grey_mode@3x.png",
                        color: state.themeMode.isDarkenedMode ? const Color(0xFF3f54d9) : null,
                        package: "epub_view",
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void rebuildTheme(EpubThemeMode colorTheme, {required ReaderSettingCubit provider}) =>
      provider.onThemeChanged(colorTheme);
}
