import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:epub_view/epub_view.dart';
import 'package:epub_view_example/core/model/epub_book/epub_book_model.dart';
import 'package:epub_view_example/service/hive/epub_book/model/epub_book_type.dart';
import 'package:epub_view_example/service/hive/hive_service.dart';
import 'package:epub_view_example/service/local_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'epub_manager_event.dart';

part 'epub_manager_state.dart';

class EpubManagerBloc extends Bloc<EpubManagerEvent, EpubManagerState> {
  EpubManagerBloc() : super(const EpubManagerState()) {
    on<FetchEpubBooksEvent>(_mapEPubBooksToState);
    on<DownloadEpubBookEvent>(_downloadEpubBook);
    on<RemoveEpubBookEvent>(_removeEpubBook);
    on<UpdateEpubBookEvent>(_updateEpubBook);
  }

  Future<void> _mapEPubBooksToState(
      FetchEpubBooksEvent event, Emitter<EpubManagerState> emit) async {
    emit(state.copyWith(status: EpubManagerStatus.loading));
    var tempDir = await getTemporaryDirectory();
    final ePubsFromAssets = await LocalService.loadEpubFromAssets() ?? [];
    List<EpubBookModel> ePubs = List.generate(
        ePubsFromAssets.length,
        (index) => EpubBookModel(
              id: index,
              title: ePubsFromAssets[index],
            ));

    List<EpubBookType> ePubsFromLocalStorage =
        await EpubBookBox().getEpubBooks();

    for (var i = 0; i < ePubs.length; i++) {
      String title = ePubs[i].title!.split("/")[2].split(".epub").join();
      bool isDownloaded =
          await EpubBookBox().isFileExists(epubId: ePubs[i].id!, title: title);

      if (isDownloaded) {
        EpubBookType currentEpub = ePubsFromLocalStorage
            .singleWhere((element) => element.id == ePubs[i].id);
        Uint8List? uInt8list = currentEpub.file;
        File file = File("${tempDir.path}/${title}_${ePubs[i].id}.epub");
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(List<int>.from(uInt8list!));
        await raf.close();
        File newFile = File(raf.path);

        ePubs[i] = ePubs[i].copyWith(
            isDownloaded: isDownloaded,
            file: newFile,
            readingProgress: ReadingProgress(
                verticalReadingParagraphProgress:
                    currentEpub.verticalReadingParagraphProgress,
                horizontalReadingPageProgress:
                    currentEpub.horizontalReadingPageProgress),
            readingSettings: ReadingSettings(
                readerMode: readerModeFromString(
                    currentEpub.readingSettings?.readerMode?.name ??
                        ReaderMode.vertical.name),
                fontSize: epubFontSizeFromString(
                    currentEpub.readingSettings?.fontSize?.name ??
                        EpubFontSize.normal.name),
                fontFamily: epubFontFamilyFromString(
                    currentEpub.readingSettings?.fontFamily?.name ??
                        EpubFontFamily.sarabun.name),
                lineHeight: EpubLineHeight.epubLineHeightFromString(
                    currentEpub.readingSettings?.lineHeight?.name ?? EpubLineHeight.factor_1_5.type.name),
                themeMode: epubThemeModeFromString(currentEpub.readingSettings?.themeMode?.name ?? EpubThemeMode.light.name)));
      }
    }

    emit(state.copyWith(status: EpubManagerStatus.success, ePubs: ePubs));
  }

  Future<void> _downloadEpubBook(
      DownloadEpubBookEvent event, Emitter<EpubManagerState> emit) async {
    int? epubNamePath = int.tryParse(event.ePubName);

    if (epubNamePath == null) return;

    String path =
        "https://mareads-staging-assets.s3.ap-southeast-1.amazonaws.com/ebook/$epubNamePath.epub";
    emit(state.copyWith(status: EpubManagerStatus.downloading));
    var tempDir = await getTemporaryDirectory();
    String savePath = "${tempDir.path}/${event.ePubName}_${event.id}.epub";
    try {
      final index = state.ePubs.indexWhere((element) => element.id == event.id);
      final currentEpub = state.ePubs[index].copyWith();
      Response response = await Dio().get(
        path,
        onReceiveProgress: (received, total) {
          // print("${(received / total * 100).toStringAsFixed(0)}%");
          if (received / total * 100 <= 90) {
            emit(state.copyWith(downloadPercent: {event.id: received / total}));
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.data == null) return;

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      emit(state.copyWith(
          downloadPercent: {event.id: 1},
          status: EpubManagerStatus.downloaded)); // 100%
      File newFile = File(raf.path);
      final updateEpub = currentEpub.copyWith(file: newFile);
      await EpubBookBox()
          .saveEpubBook(ePub: updateEpub.copyWith(title: event.ePubName));
      emit(state.copyWith(
        status: EpubManagerStatus.success,
        downloadPercent: {0: 0}, // Download is done.
        ePubs: state.ePubs..[index] = updateEpub.copyWith(isDownloaded: true),
      ));
    } on DioError catch (e) {
      emit(state.copyWith(status: EpubManagerStatus.error));
      throw e.message.toString();
    }
  }

  Future<void> _removeEpubBook(
      RemoveEpubBookEvent event, Emitter<EpubManagerState> emit) async {
    emit(state.copyWith(status: EpubManagerStatus.removing));
    Map<int, double> mapRemovePercent = {event.id: 50};

    emit(state.copyWith(removePercent: mapRemovePercent));
    final isSuccess =
        await EpubBookBox().deleteBook(epubId: event.id, title: event.ePubName);
    if (!isSuccess) {
      emit(state
          .copyWith(status: EpubManagerStatus.success, removePercent: {0: 0}));
      return;
    }
    mapRemovePercent = {event.id: 80};
    emit(state.copyWith(removePercent: mapRemovePercent));
    List<EpubBookModel> ePubs = List.from(state.ePubs);

    final ePub = ePubs
        .singleWhere((element) => element.id == event.id)
        .copyWith(file: null, isDownloaded: false);
    int index = ePubs.indexWhere((element) => element.id == event.id);
    mapRemovePercent = {event.id: 100};
    emit(state.copyWith(
        status: EpubManagerStatus.removed, removePercent: mapRemovePercent));

    emit(state.copyWith(
      status: EpubManagerStatus.success,
      ePubs: state.ePubs..[index] = ePub,
      removePercent: {0: 0},
    ));
  }

  Future<void> _updateEpubBook(
      UpdateEpubBookEvent event, Emitter<EpubManagerState> emit) async {
    EpubBookModel epubBook =
        state.ePubs.singleWhere((element) => element.id == event.ePubId);
    String title = epubBook.title!.split("/")[2].split(".epub").join();

    if (int.tryParse(title) == null) {
      if (event.onSuccess != null) event.onSuccess!.call();
      return;
    }

    final epubType =
        await EpubBookBox().getEpubBook(epubId: event.ePubId, title: title);
    int difference =
        DateTime.parse(epubType.updateTime!).difference(DateTime.now()).inDays;

    if (difference.isNegative) {
      String path =
          "https://mareads-staging-assets.s3.ap-southeast-1.amazonaws.com/ebook/${int.parse(title)}.epub";
      emit(state.copyWith(status: EpubManagerStatus.updating));

      var tempDir = await getTemporaryDirectory();
      String savePath = "${tempDir.path}/${title}_${event.ePubId}.epub";

      final index =
          state.ePubs.indexWhere((element) => element.id == event.ePubId);
      final currentEpub = state.ePubs[index].copyWith();
      Response response = await Dio().get(
        path,
        onReceiveProgress: (received, total) {
          if (received / total * 100 <= 90) {
            emit(state.copyWith(updatePercent: received / total));
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.data != null) {
        File file = File(savePath);
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        emit(state.copyWith(updatePercent: 1)); // 100%
        await EpubBookBox().deleteBook(epubId: event.ePubId, title: title);
        File newFile = File(raf.path);
        final updateEpub = currentEpub.copyWith(file: newFile);
        await EpubBookBox()
            .saveEpubBook(ePub: updateEpub.copyWith(title: title));
        emit(state.copyWith(
          updatePercent: 0, // Download is done.
          ePubs: state.ePubs..[index] = updateEpub.copyWith(isDownloaded: true),
        ));
      }

      emit(state.copyWith(status: EpubManagerStatus.updated));
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (event.onSuccess != null) {
      emit(state.copyWith(status: EpubManagerStatus.success));
      event.onSuccess!.call();
    }
  }
}
