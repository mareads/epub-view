import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/painter/slider_custom.dart';
import 'package:flutter/material.dart';

class BrightnessSettingWidget extends StatelessWidget {
  const BrightnessSettingWidget({
    Key? key,
    required this.themeMode,
    required this.brightNessValue,
    required this.onChanged,
  }) : super(key: key);

  final EpubThemeMode themeMode;
  final double brightNessValue;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ความสว่างหน้าจอ"),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/brightness_setting@3x.png",
              width: 30,
              height: 30,
              color: themeMode.data.textColor,
              package: "epub_view",
            ),
            const SizedBox(width: 15),
            // SvgPicture.asset(
            //   'assets/icons/brightness_settings_icon.svg',
            //   color: Colors.black,
            //   semanticsLabel: 'A red up arrow',
            //   width: 30,
            //   height: 30,
            // ),
            // const SizedBox(width: 10),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                trackShape: CustomTrackShape(),
                thumbShape: CircleThumbShape(
                  thumbRadius: 15,
                  color: themeMode.isDarkenedMode ? const Color(0xff818181) : null,
                ),
                thumbColor: const Color(0xFF3F54D9).withOpacity(.8),
                activeTrackColor: const Color(0xFF3F54D9),
                inactiveTrackColor: themeMode.data.brightnessBackgroundColor,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 1),
              ),
              child: Expanded(
                child: Slider(
                  value: brightNessValue,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
