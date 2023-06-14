import 'package:epub_view/src/data/setting/theme_setting.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/setting/src/reader_mode.dart';

class ReaderTypeWidget extends StatelessWidget {
  const ReaderTypeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ลักษณะการอ่าน"),
        const SizedBox(height: 8),
        BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
          bloc: context.read<ReaderSettingCubit>(),
          buildWhen: (prev, cur) =>
              prev.readerMode != cur.readerMode || prev.themeMode != cur.themeMode,
          builder: (_, state) {
            return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: ReaderMode.values.map((e) {
                  final isSelected = e == state.readerMode;
                  Color backgroundColor = context
                      .read<ReaderSettingCubit>()
                      .getBackgroundColor(
                          context: context, isSelected: isSelected);
                  Color? iconColor = context
                      .read<ReaderSettingCubit>()
                      .getIconColor(context: context, isSelected: isSelected);

                  return Opacity(
                    opacity: isSelected ? 1 : .6,
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) return;
                        context.read<ReaderSettingCubit>().onReaderModeChanged(e);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : state.themeMode.data.borderColor),
                          boxShadow: isSelected && !state.themeMode.isDarkenedMode
                              ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(.4),
                              offset: const Offset(2, 3),
                              blurRadius: 10,
                              spreadRadius: -3,
                            ),
                          ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: e.isVertical ? 3.14159 / 2 : 0,
                          child: SvgPicture.asset(
                            "assets/icons/scroll_direction.svg",
                            package: "epub_view",
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList());
          },
        )
      ],
    );
  }
}
