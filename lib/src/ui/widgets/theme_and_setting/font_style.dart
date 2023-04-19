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
        // SizedBox(
        //   height: 40,
        //   child: DropdownButtonFormField(
        //     decoration: const InputDecoration(border: OutlineInputBorder()),
        //     value: "Font1",
        //     items: List.generate(
        //       4,
        //       (i) => DropdownMenuItem(
        //         alignment: Alignment.topCenter,
        //         value: "Font${i + 1}",
        //         child: Text("Font${i + 1}"),
        //       ),
        //     ).toList(),
        //     onChanged: (value) {
        //       //
        //     },
        //   ),
        // )
        BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
          builder: (_, state) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFeeeeee)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
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
              ),
            );
          },
        ),
      ],
    );
  }
}
