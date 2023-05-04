// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epub_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EpubBookModel _$EpubBookModelFromJson(Map<String, dynamic> json) =>
    EpubBookModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      updateTime: json['updateTime'] as String?,
      file: FileConverter.getFile(json['file']),
      isDownloaded: json['isDownloaded'] as bool?,
    );

Map<String, dynamic> _$EpubBookModelToJson(EpubBookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'updateTime': instance.updateTime,
      'file': FileConverter.getBytes(instance.file),
      'isDownloaded': instance.isDownloaded,
    };
