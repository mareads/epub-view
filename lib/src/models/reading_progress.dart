class ReadingProgress {
  final int? readingParagraphProgress;
  final int? readingChapterProgress;
  const ReadingProgress({
    this.readingParagraphProgress,
    this.readingChapterProgress,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      readingParagraphProgress: json["readingParagraphProgress"]?.toInt(),
      readingChapterProgress: json["readingChapterProgress"]?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (readingParagraphProgress != null)
          'readingParagraphProgress': readingParagraphProgress,
        'readingChapterProgress': readingChapterProgress,
      };
}
