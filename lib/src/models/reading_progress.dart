class ReadingProgress {
  final int? readingParagraphProgress;
  final int? readingChapterProgress;
  final bool? isNotFinish;
  const ReadingProgress({
    this.readingParagraphProgress,
    this.readingChapterProgress,
    this.isNotFinish,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      readingParagraphProgress: json["readingParagraphProgress"]?.toInt(),
      readingChapterProgress: json["readingChapterProgress"]?.toInt(),
      isNotFinish: json["isNotFinish"]?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (readingParagraphProgress != null)
          'readingParagraphProgress': readingParagraphProgress,
        'readingChapterProgress': readingChapterProgress,
        'isNotFinish': isNotFinish,
      };
}
