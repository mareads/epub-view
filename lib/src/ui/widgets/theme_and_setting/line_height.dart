import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LineHeightWidget extends StatelessWidget {
  const LineHeightWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ระยะห่างระหว่างบันทัด"),
        const SizedBox(height: 8),
        BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
          bloc: context.read<ReaderSettingCubit>(),
          builder: (_, state) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: EpubLineHeight.values.asMap().entries.map<Widget>((item) {
                bool isSelected = state.lineHeight.type == item.value.type;
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

                return Opacity(
                  opacity: isSelected ? 1 : .6,
                  child: GestureDetector(
                    onTap: () {
                      if (isSelected) return;
                      context.read<ReaderSettingCubit>().onLineHeightChanged(item.value);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(right: item.key == 4 ? 0 : 20),
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
                        "assets/icons/line_spaces/line_space_${item.key + 1}.svg",
                        color: iconColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        )
      ],
    );
  }
}
