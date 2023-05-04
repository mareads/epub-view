import 'dart:io';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'epub_book_model.g.dart';

@JsonSerializable()
class EpubBookModel {
  final int? id;
  final String? title;
  final String? updateTime;
  @JsonKey(name: "file", fromJson: FileConverter.getFile, toJson: FileConverter.getBytes)
  File? file;
  final bool? isDownloaded;

  EpubBookModel({this.id, this.title, this.updateTime, this.file, this.isDownloaded});

  EpubBookModel copyWith({
    int? id,
    String? title,
    String? updateTime,
    File? file,
    bool? isDownloaded,
  }) {
    return EpubBookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      file: file ?? this.file,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  factory EpubBookModel.fromJson(Map<String, dynamic> json) => _$EpubBookModelFromJson(json);
  Map<String, dynamic> toJson() => _$EpubBookModelToJson(this);
}

class FileConverter extends JsonConverter<File, List<int>?> {
  const FileConverter();

  @override
  File fromJson(Object? json) {
    if (json is List<int>) {
      Uint8List uInt8list = Uint8List.fromList(json);
      return File.fromRawPath(uInt8list);
    }

    if (json is File) {
      return json;
    }

    throw StateError("FileConverter was wrong converting Type-Object");
  }

  static File getFile(Object? json) => const FileConverter().fromJson(json);

  @override
  List<int>? toJson(File object) {
    Uint8List uInt8list = object.readAsBytesSync();
    return List<int>.from(uInt8list);
  }

  static List<int>? getBytes(File? object) => object == null ? null : const FileConverter().toJson(object);
}
