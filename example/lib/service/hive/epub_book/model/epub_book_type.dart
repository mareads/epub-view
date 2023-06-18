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

  @HiveField(5)
  final int? readingChapterProgress;

  @HiveField(6)
  final bool? isReading;

  // @HiveField(5)
  // final ReadingSettingsType? readingSettings;

  EpubBookType({
    this.id,
    this.title,
    this.updateTime,
    this.file,
    this.readingParagraphProgress,
    this.readingChapterProgress,
    this.isReading,
    // this.readingSettings,
  });

  EpubBookType copyWith({
    int? id,
    String? title,
    String? updateTime,
    Uint8List? file,
    int? readingParagraphProgress,
    int? readingChapterProgress,
    bool? isReading,
    // ReadingSettingsType? readingSettings,
  }) {
    return EpubBookType(
      id: id ?? this.id,
      isReading: isReading ?? this.isReading,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      file: file ?? this.file,
      readingParagraphProgress:
          readingParagraphProgress ?? this.readingParagraphProgress,
      readingChapterProgress:
          readingChapterProgress ?? this.readingChapterProgress,
      // readingSettings: readingSettings ?? this.readingSettings,
    );
  }

  factory EpubBookType.fromJson(Map<String, dynamic> json) {
    return EpubBookType(
      id: json["id"]?.toInt(),
      isReading: json["isReading"],
      title: json["title"]?.toString(),
      updateTime: json["updateTime"]?.toString(),
      file: json["file"],
      readingParagraphProgress: json["readingParagraphProgress"],
      readingChapterProgress: json["readingChapterProgress"],
      // readingSettings: json["readingSettings"],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (isReading != null) 'isReading': isReading,
        if (title != null) 'title': title,
        if (updateTime != null) 'updateTime': updateTime,
        if (file != null) 'file': file,
        if (readingParagraphProgress != null)
          'readingParagraphProgress': readingParagraphProgress,
        if (readingChapterProgress != null)
          'readingChapterProgress': readingChapterProgress,
        // if (readingSettings != null) 'readingSettings': readingSettings,
      };

  @override
  List<Object?> get props => [
        id, title, updateTime, isReading, file, readingParagraphProgress,
        readingChapterProgress
        // readingSettings
      ];
}
