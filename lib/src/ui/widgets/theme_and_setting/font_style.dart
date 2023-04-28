import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:epub_view/src/data/setting/src/epub_font_family.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FontsStyleWidget extends StatelessWidget {
  const FontsStyleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ฟอนต์"),
        const SizedBox(height: 8),
        BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
          builder: (_, state) {
            return DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                buttonStyleData: ButtonStyleData(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    color: state.themeMode.data.backgroundColor,
                    border: Border.all(color: state.themeMode.data.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  elevation: 0,
                ),
                iconStyleData: IconStyleData(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconEnabledColor: Theme.of(context).colorScheme.primary,
                  iconDisabledColor: Colors.grey,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 140,
                  padding: null,
                  decoration: BoxDecoration(
                    border: Border.all(color: state.themeMode.data.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: state.themeMode.data.backgroundColor,
                  ),
                  elevation: 0,
                  offset: const Offset(0, 0),
                  scrollbarTheme: ScrollbarThemeData(
                    thumbVisibility: MaterialStateProperty.all(false),
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 30,
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  selectedMenuItemBuilder: (_, child) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    color: barrierSelectedColor(state.themeMode),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Text(
                      state.fontFamily.shortName,
                      style: GoogleFonts.sarabun(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: state.themeMode.isDarkMode
                            ? const Color(0xffffffff)
                            : const Color(0xff3f54d9),
                      ),
                    ),
                  ),
                ),
                value: state.fontFamily.shortName,
                items: EpubFontFamily.values
                    .map((fontFamily) => DropdownMenuItem(
                          value: fontFamily.shortName,
                          child: Text(
                            fontFamily.shortName,
                            style: GoogleFonts.sarabun(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: state.themeMode.data.textColor,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (name) {
                  final fontFamily = EpubFontFamily.values.singleWhere(
                      (element) => element.shortName == name,
                      orElse: () => EpubFontFamily.sarabun);
                  context.read<ReaderSettingCubit>().onFontFamilyChanged(fontFamily);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Color barrierSelectedColor(EpubThemeMode mode) {
    switch(mode) {
      case  EpubThemeMode.light:
        return const Color(0xfff1f9ff);
      case  EpubThemeMode.sepia:
        return const Color(0xfff0ede6);
      case  EpubThemeMode.dark:
        return const Color(0xff343434);
      case  EpubThemeMode.darkened:
        return const Color(0xff22284a);
    }
  }
}
