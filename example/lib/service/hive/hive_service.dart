import 'dart:typed_data';

import 'package:epub_view/epub_view.dart' show Hive;
import 'package:epub_view_example/core/model/epub_book/epub_book_model.dart';

import 'epub_book/model/epub_book_type.dart';

part 'epub_book/epub_book_box.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  HiveService._internal();

  factory HiveService() => _instance;

  Future<void> initialize() async {
    EpubBookBox.registerAdapters();
    await EpubBookBox().openEpubBookBoxes();
  }
}