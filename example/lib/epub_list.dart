import 'dart:developer';
import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:epub_view_example/bloc/epub_manager_bloc.dart';
import 'package:epub_view_example/core/model/epub_book/epub_book_model.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/font_family.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/font_size.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/line_height.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/reader_mode.dart';
import 'package:epub_view_example/service/hive/epub_book/model/enums/theme_mode.dart';
import 'package:epub_view_example/service/hive/epub_book/model/reading_settings.dart';
import 'package:epub_view_example/service/hive/hive_service.dart';
import 'package:epub_view_example/widgets/epub_book.dart';
import 'package:epub_view_example/widgets/update_percent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EpubListScreen extends StatelessWidget {
  const EpubListScreen(
      {Key? key,
      required this.mapPercentDownload,
      required this.mapPercentDelete,
      required this.data})
      : super(key: key);

  final Map<int, double> mapPercentDownload;
  final Map<int, double> mapPercentDelete;
  final List<EpubBookModel> data;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpubManagerBloc, EpubManagerState>(
      builder: (_, state) {
        return Stack(
          children: [
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: ((164 + 10 + 10) / 397),
              ),
              itemCount: data.length,
              itemBuilder: (_, int index) {
                String title = (data[index].title ?? "")
                    .split("/")[2]
                    .split(".epub")
                    .join();

                return GestureDetector(
                  onTap: () {
                    if (int.tryParse(title) != null &&
                        !(data[index].isDownloaded ?? false)) {
                      SnackBar snackBar = SnackBar(
                        content: const Text(
                            "You need to download before opening the file."),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    context.read<EpubManagerBloc>().add(UpdateEpubBookEvent(
                          ePubId: data[index].id!,
                          onSuccess: () async {
                            await Navigator.push(
                              _,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      _EpubViewReader(epubBook: data[index])),
                            );
                          },
                        ));
                  },
                  child: EpubBookCardView(
                    title: title,
                    percent: mapPercentDownload.keys.first == data[index].id!
                        ? mapPercentDownload.values.first
                        : 0,
                    isForceDownload: int.tryParse(title) != null,
                    isDownloaded: data[index].isDownloaded ?? false,
                    isDeleting:
                        mapPercentDelete.keys.first == data[index].id! &&
                            mapPercentDelete.values.first > 0,
                    onDownload: () {
                      context.read<EpubManagerBloc>().add(DownloadEpubBookEvent(
                            ePubName: title,
                            id: data[index].id!,
                          ));
                    },
                    onDeleted: () {
                      context.read<EpubManagerBloc>().add(RemoveEpubBookEvent(
                            ePubName: title,
                            id: data[index].id!,
                          ));
                    },
                  ),
                );
              },
            ),
            if (state.status.isUpdating)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black54,
                child: Dialog(
                    child: UpdatePercentDialog(value: state.updatePercent)),
              )
          ],
        );
      },
    );
  }
}

class _EpubViewReader extends StatefulWidget {
  const _EpubViewReader({Key? key, required this.epubBook}) : super(key: key);

  final EpubBookModel epubBook;

  @override
  State<_EpubViewReader> createState() => _EpubViewReaderState();
}

class _EpubViewReaderState extends State<_EpubViewReader> {
  late EpubController _epubReaderController;

  late String epubFromAsset;
  late File? epubFromFile;

  @override
  void initState() {
    epubFromAsset = widget.epubBook.title ?? "";
    epubFromFile =
        (widget.epubBook.isDownloaded ?? false) ? widget.epubBook.file : null;
    if (epubFromFile != null) {
      _epubReaderController = EpubController(
        document: EpubDocument.openFile(epubFromFile!),
      );
    } else {
      _epubReaderController = EpubController(
        document: EpubDocument.openAsset(epubFromAsset),
        // epubCfi:
        //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
        // epubCfi:
        //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  Future<void> _onEpubExit({
    required ReadingProgress readingProgress,
  }) async {
    await EpubBookBox().saveProgressEpubBook(
      ePub: widget.epubBook,
      readingProgress: ReadingProgress(
        readingParagraphProgress: readingProgress.readingParagraphProgress,
        readingChapterProgress: readingProgress.readingChapterProgress,
      ),
      // readingSettings: ReadingSettingsType(
      //     readerMode:
      //         readerModeEnumTypeFromString(readingSettings.readerMode!.name),
      //     fontSize:
      //         fontSizeEnumTypeFromString(readingSettings.fontSize!.name),
      //     fontFamily:
      //         fontFamilyEnumTypeFromString(readingSettings.fontFamily!.name),
      //     lineHeight: lineHeightEnumTypeFromString(
      //         readingSettings.lineHeight!.type.name),
      //     themeMode:
      //         themeModeEnumTypeFromString(readingSettings.themeMode!.name))
    );

    context.read<EpubManagerBloc>().add(FetchEpubBooksEvent());
  }

  @override
  Widget build(BuildContext context) {
    inspect("widget.epubBook.readingProgress,");
    inspect(widget.epubBook.readingProgress);
    return Scaffold(
      body: EpubView(
        initReadingProgress: widget.epubBook.readingProgress,
        onEpubExit: _onEpubExit,
        // initReadingSettings: widget.epubBook.readingSettings,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
              textStyle: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w300, height: 1.5),
            ),
            chapterDividerBuilder: (_) => const Divider(),
            loaderBuilder: (ctx) {
              return const CircularProgressIndicator(
                color: Colors.blue,
              );
            }),
        controller: _epubReaderController,
      ),
    );
  }

  // void _showCurrentEpubCfi(context) {
  //   final cfi = _epubReaderController.generateEpubCfi();
  //
  //   if (cfi != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(cfi),
  //         action: SnackBarAction(
  //           label: 'GO',
  //           onPressed: () {
  //             _epubReaderController.gotoEpubCfi(cfi);
  //           },
  //         ),
  //       ),
  //     );
  //   }
  // }
}
