import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:epub_view_example/service/hive/epub_book/model/reading_settings.dart';

part 'epub_book_type.g.dart';

@HiveType(typeId: 0)
class EpubBookType extends HiveObject with EquatableMixin {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? title;

  @HiveField(2)
  final String? updateTime;

  @HiveField(3)
  final Uint8List? file;

  @HiveField(4)
  final int? readingParagraphProgress;

  // @HiveField(5)
  // final ReadingSettingsType? readingSettings;

  EpubBookType({
    this.id,
    this.title,
    this.updateTime,
    this.file,
    this.readingParagraphProgress,
    // this.readingSettings,
  });

  EpubBookType copyWith({
    int? id,
    String? title,
    String? updateTime,
    Uint8List? file,
    int? readingParagraphProgress,
    // ReadingSettingsType? readingSettings,
  }) {
    return EpubBookType(
      id: id ?? this.id,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      file: file ?? this.file,
      readingParagraphProgress:
          readingParagraphProgress ?? this.readingParagraphProgress,
      // readingSettings: readingSettings ?? this.readingSettings,
    );
  }

  factory EpubBookType.fromJson(Map<String, dynamic> json) {
    return EpubBookType(
      id: json["id"]?.toInt(),
      title: json["title"]?.toString(),
      updateTime: json["updateTime"]?.toString(),
      file: json["file"],
      readingParagraphProgress: json["readingParagraphProgress"],
      // readingSettings: json["readingSettings"],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (updateTime != null) 'updateTime': updateTime,
        if (file != null) 'file': file,
        if (readingParagraphProgress != null)
          'readingParagraphProgress': readingParagraphProgress,
        // if (readingSettings != null) 'readingSettings': readingSettings,
      };

  @override
  List<Object?> get props => [
        id, title, updateTime, file, readingParagraphProgress,
        // readingSettings
      ];
}
