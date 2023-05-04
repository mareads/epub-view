import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';

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

  EpubBookType({
    this.id,
    this.title,
    this.updateTime,
    this.file,
  });

  EpubBookType copyWith({
    int? id,
    String? title,
    String? updateTime,
    Uint8List? file,
  }) {
    return EpubBookType(
      id: id ?? this.id,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      file: file ?? this.file,
    );
  }

  factory EpubBookType.fromJson(Map<String, dynamic> json) {
    return EpubBookType(
      id: json["id"]?.toInt(),
      title: json["title"]?.toString(),
      updateTime: json["updateTime"]?.toString(),
      file: json["file"],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (updateTime != null) 'updateTime': updateTime,
        if (file != null) 'file': file,
      };

  @override
  List<Object?> get props => [id, title, updateTime, file];
}
