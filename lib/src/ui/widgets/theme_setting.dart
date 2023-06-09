import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:epub_view/src/ui/widgets/theme_and_setting/reader_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'theme_and_setting/brightness_setting.dart';
import 'theme_and_setting/font_size.dart';
import 'theme_and_setting/font_style.dart';
import 'theme_and_setting/line_height.dart';
import 'theme_and_setting/theme_mode.dart';

class ThemeSettingPanel extends StatefulWidget {
  const ThemeSettingPanel({Key? key, required this.animation})
      : super(key: key);

  final Animation<double> animation;

  @override
  State<ThemeSettingPanel> createState() => _ThemeSettingPanelState();
}

class _ThemeSettingPanelState extends State<ThemeSettingPanel> {
  double _brightnessLevel = 0;

  Future<void> _setCurrentBrightness() async {
    final brightness = await currentBrightness;
    _setBrightness(brightness);
  }

  Future<double> get currentBrightness async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to get current brightness';
    }
  }

  void _setBrightness(double brightness) {
    setState(() {
      _brightnessLevel = brightness;
      _setDeviceBrightness(brightness: _brightnessLevel);
    });
  }

  Future<void> _setDeviceBrightness({required double brightness}) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set brightness';
    }
  }

  @override
  void initState() {
    super.initState();
    _setCurrentBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      builder: (_, state) => Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: FadeTransition(
          opacity: widget.animation,
          child: Stack(
            children: [
              InkWell(
                onTap: () => context.read<ReaderSettingCubit>().onToggleSettingSection(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(.3),
                ),
              ),
              Material(
                elevation: 8.0,
                color: state.themeMode.data.backgroundColor,
                textStyle: GoogleFonts.mitr(
                  fontSize: 14,
                  color: state.themeMode.data.textColor,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height -
                        (kToolbarHeight * 2 + 78),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: state.themeMode.data.borderColor)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 6,
                    itemBuilder: (_, i) => [
                      BrightnessSettingWidget(
                        themeMode: state.themeMode,
                        brightNessValue: _brightnessLevel,
                        onChanged: _setBrightness,
                      ),
                      const AppThemeModeWidget(),
                      const FontsStyleWidget(),
                      const FontsSizeWidget(),
                      const LineHeightWidget(),
                      const ReaderTypeWidget(),
                    ][i],
                    separatorBuilder: (_, __) =>
                        _Spacing(dividerColor: state.themeMode.data.dividerColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Spacing extends StatelessWidget {
  const _Spacing({Key? key, required this.dividerColor}) : super(key: key);

  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 20),
      ],
    );
  }
}
