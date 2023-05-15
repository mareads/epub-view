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
  final int? verticalReadingParagraphProgress;

  @HiveField(5)
  final int? horizontalReadingPageProgress;

  @HiveField(6)
  final ReadingSettingsType? readingSettings;

  EpubBookType({
    this.id,
    this.title,
    this.updateTime,
    this.file,
    this.verticalReadingParagraphProgress,
    this.horizontalReadingPageProgress,
    this.readingSettings,
  });

  EpubBookType copyWith({
    int? id,
    String? title,
    String? updateTime,
    Uint8List? file,
    int? verticalReadingParagraphProgress,
    int? horizontalReadingPageProgress,
    ReadingSettingsType? readingSettings,
  }) {
    return EpubBookType(
      id: id ?? this.id,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      file: file ?? this.file,
      verticalReadingParagraphProgress: verticalReadingParagraphProgress ??
          this.verticalReadingParagraphProgress,
      horizontalReadingPageProgress:
          horizontalReadingPageProgress ?? this.horizontalReadingPageProgress,
      readingSettings: readingSettings ?? this.readingSettings,
    );
  }

  factory EpubBookType.fromJson(Map<String, dynamic> json) {
    return EpubBookType(
      id: json["id"]?.toInt(),
      title: json["title"]?.toString(),
      updateTime: json["updateTime"]?.toString(),
      file: json["file"],
      horizontalReadingPageProgress: json["horizontalReadingPageProgress"],
      verticalReadingParagraphProgress:
          json["verticalReadingParagraphProgress"],
      readingSettings: json["readingSettings"],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (updateTime != null) 'updateTime': updateTime,
        if (file != null) 'file': file,
        if (horizontalReadingPageProgress != null)
          'horizontalReadingPageProgress': horizontalReadingPageProgress,
        if (verticalReadingParagraphProgress != null)
          'verticalReadingParagraphProgress': verticalReadingParagraphProgress,
        if (readingSettings != null) 'readingSettings': readingSettings,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        updateTime,
        file,
        verticalReadingParagraphProgress,
        horizontalReadingPageProgress,
        readingSettings
      ];
}
