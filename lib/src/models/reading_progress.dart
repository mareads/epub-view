class ReadingProgress {
  final int? horizontalReadingPageProgress;
  final int? verticalReadingParagraphProgress;
  const ReadingProgress({
    this.horizontalReadingPageProgress,
    this.verticalReadingParagraphProgress,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      horizontalReadingPageProgress:
          json["horizontalReadingPageProgress"]?.toInt(),
      verticalReadingParagraphProgress:
          json["verticalReadingParagraphProgress"]?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (horizontalReadingPageProgress != null)
          'horizontalReadingPageProgress': horizontalReadingPageProgress,
        if (verticalReadingParagraphProgress != null)
          'verticalReadingParagraphProgress': verticalReadingParagraphProgress,
      };
}
