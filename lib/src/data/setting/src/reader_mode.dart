enum ReaderMode { horizontal, vertical }

extension ReaderModeX on ReaderMode {
  bool get isHorizontal => this == ReaderMode.horizontal;

  bool get isVertical => this == ReaderMode.vertical;
}
