import 'package:html/dom.dart';

class ChapterParagraphs {
  ChapterParagraphs({required this.paragraphs, required this.chapterNo});

  final List<Element> paragraphs;
  final int chapterNo;
}
