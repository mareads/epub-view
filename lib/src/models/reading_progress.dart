class ReadingProgress {
  final int? readingParagraphProgress;
  const ReadingProgress({
    this.readingParagraphProgress,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      readingParagraphProgress: json["readingParagraphProgress"]?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (readingParagraphProgress != null)
          'readingParagraphProgress': readingParagraphProgress,
      };
}
