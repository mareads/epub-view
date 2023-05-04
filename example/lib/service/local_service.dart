import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalService {
  static Future<List<String>?> loadEpubFromAssets() async {
    final list = await json
        .decode(await rootBundle.loadString('AssetManifest.json'))
        .keys
        .where((String key) => key.contains('assets/epub_books/'))
        .toList();
    return list;
  }

  static Future<void> permissionStorage({required Function callback}) async {
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      // access media location needed for android 10/Q
      await Permission.accessMediaLocation.request();
      // manage external storage needed for android 11/R
      await Permission.manageExternalStorage.request();
      callback.call();
    } else {
      callback.call();
    }
  }
}