import 'package:epub_view/src/data/setting/src/epub_font_size.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FontsSizeWidget extends StatelessWidget {
  const FontsSizeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ขนาดตัวอักษร"),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...List.generate(
                  6,
                  (index) {
                    bool isSelected = EpubFontSize.values[index] == state.fontSize;
                    Color backgroundColor = state.themeMode.isDarkenedMode
                        ? isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(.3)
                            : state.themeMode.data.buttonBackgroundColor
                        : state.themeMode.data.buttonBackgroundColor;
                    Color? iconColor = isSelected
                        ? state.themeMode.isDarkenedMode
                            ? Theme.of(context).colorScheme.secondary
                            : null
                        : state.themeMode.isDarkMode
                            ? const Color(0xff0c1135)
                            : state.themeMode.data.textColor;

                    return IgnorePointer(
                      ignoring: isSelected,
                      child: Opacity(
                        opacity: isSelected ? 1 : .6,
                        child: GestureDetector(
                          onTap: () => context
                              .read<ReaderSettingCubit>()
                              .onFontSizeChanged(EpubFontSize.values[index]),
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.only(right: index == 5 ? 0 : 20),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.secondary
                                      : state.themeMode.data.borderColor),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/icons/font_sizes/font_size_${index + 1}.svg",
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }
}
