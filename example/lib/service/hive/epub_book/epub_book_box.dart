part of '../hive_service.dart';

class EpubBookBox {
  static final EpubBookBox _instance = EpubBookBox._internal();

  EpubBookBox._internal();

  factory EpubBookBox() => _instance;

  static void registerAdapters() {
    Hive.registerAdapter(EpubBookTypeAdapter());
    Hive.registerAdapter(ReadingSettingsTypeAdapter());
    Hive.registerAdapter(FontFamilyEnumTypeAdapter());
    Hive.registerAdapter(FontSizeEnumTypeAdapter());
    Hive.registerAdapter(LineHeightEnumTypeAdapter());
    Hive.registerAdapter(ReaderModeEnumTypeAdapter());
    Hive.registerAdapter(ThemeModeEnumTypeAdapter());
  }

  Future<void> openEpubBookBoxes() async =>
      await Hive.openLazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);

  Future<bool> isFileExists(
      {required int epubId, required String title}) async {
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    final book = await box.get("${epubId}_$title");
    return book != null;
  }

  Future<List<EpubBookType>> getEpubBooks() async {
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    List<EpubBookType> books = [];

    for (String key in box.keys.toList()) {
      final book = await box.get(key);
      books.add(book!);
    }

    return books;
  }

  Future<EpubBookType> getEpubBook(
      {required int epubId, required String title}) async {
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    final book = await box.get("${epubId}_$title");
    return book!;
  }

  Future<void> saveProgressEpubBook(
      {required EpubBookModel ePub,
      required ReadingProgress readingProgress,
      required ReadingSettingsType readingSettings}) async {
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    String title = ePub.title!.split("/")[2].split(".epub").join();
    String key = "${ePub.id!}_$title";

    EpubBookType? currentBook = await box.get(key);
    final updateBook = currentBook!.copyWith(
        readingSettings: readingSettings,
        horizontalReadingPageProgress:
            readingProgress.horizontalReadingPageProgress,
        verticalReadingParagraphProgress:
            readingProgress.verticalReadingParagraphProgress);
    await box.put(key, updateBook);
  }

  Future<void> saveEpubBook({required EpubBookModel ePub}) async {
    DateTime now = DateTime.now().toUtc();
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    String key = "${ePub.id!}_${ePub.title!}";

    Uint8List bytesData = ePub.file!.readAsBytesSync();

    if (box.containsKey(key)) {
      EpubBookType? currentBook = await box.get(key);
      final updateBook = currentBook!.copyWith(
        updateTime: now.toIso8601String(),
        file: bytesData,
      );
      await box.put(key, updateBook);
    } else {
      EpubBookType epubBookType = EpubBookType(
        id: ePub.id!,
        title: ePub.title!,
        updateTime: now.toIso8601String(),
        file: bytesData,
      );
      await box.put(key, epubBookType);
    }
  }

  Future<bool> deleteBook({required int epubId, required String title}) async {
    final box = Hive.lazyBox<EpubBookType>(HiveBoxCollections.epubBookBoxKey);
    final book = await box.get("${epubId}_$title");
    if (book != null) {
      await box.delete("${epubId}_$title");
      return true;
    } else {
      return false;
    }
  }
}

class HiveBoxCollections {
  static const int epubBookBoxId = 0;

  static const String epubBookBoxKey = "epub-book-box-key";
}
