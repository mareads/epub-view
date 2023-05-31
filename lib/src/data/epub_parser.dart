import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:epub_view/src/data/models/chapter_paragraphs.dart';
import 'package:epub_view/src/models/paragraph_progress.dart';
import 'package:html/dom.dart' as dom;

import 'models/paragraph.dart';

export 'package:epubx/epubx.dart' hide Image;

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.Chapters!.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.SubChapters!.forEach(acc.add);
        return acc;
      },
    );

List<dom.Element> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.children;

List<dom.Element> _removeAllDiv(List<dom.Element> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node.localName == 'div' && node.children.length > 1) {
      result.addAll(_removeAllDiv(node.children));
    } else {
      result.add(node);
    }
  }

  return result;
}

// List<ParagraphProgress> paragraphProgressList(
//     {required List<Paragraph> paragraphs}) {
//   final List<ParagraphProgress> paragraphProgressList = [];
//   int prevChapterId = 0;
//   int paragraphCount = 0;
//   int loopCount = 0;
//   for (final paragraph in paragraphs) {
//     paragraphProgressList.add(ParagraphProgress(
//         chapterIndex: paragraph.chapterIndex,
//         paragraphIndex: prevChapterId == paragraph.chapterIndex
//             ? paragraphCount
//             : paragraphCount = 0,
//         paragraphProgressIndex: loopCount));
//     prevChapterId = paragraph.chapterIndex;
//     paragraphCount++;
//     loopCount++;
//   }
//   return paragraphProgressList;
// }

bool isEmptyElement(dom.Element element) {
  return element.nodes.isNotEmpty || element.localName == "img";
}

ParseParagraphsResult parseParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  String? filename = '';
  final List<int> chapterIndexes = [];
  final paragraphs = chapters.fold<List<Paragraph>>(
    [],
    (acc, next) {
      List<dom.Element> elmList = [];
      if (filename != next.ContentFileName) {
        filename = next.ContentFileName;
        final document = EpubCfiReader().chapterDocument(next);
        if (document != null) {
          final result = convertDocumentToElements(document);
          elmList = _removeAllDiv(result);
        }
      }

      if (next.Anchor == null) {
        // last element from document index as chapter index
        chapterIndexes.add(acc.length);
        acc.addAll(elmList
            .map((element) => Paragraph(element, chapterIndexes.length - 1)));
        return acc;
      } else {
        final index = elmList.indexWhere(
          (elm) => elm.outerHtml.contains(
            'id="${next.Anchor}"',
          ),
        );
        if (index == -1) {
          chapterIndexes.add(acc.length);
          acc.addAll(elmList
              .map((element) => Paragraph(element, chapterIndexes.length - 1)));
          return acc;
        }

        chapterIndexes.add(index);
        acc.addAll(elmList
            .map((element) => Paragraph(element, chapterIndexes.length - 1)));
        return acc;
      }
    },
  );

  return ParseParagraphsResult(paragraphs, chapterIndexes);
}

List<ChapterParagraphs?> parseChapterParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  String? filename = '';
  int chapterIndex = 0;
  final paragraphs = chapters.map<ChapterParagraphs?>((chapter) {
    List<dom.Element> elmList = [];
    if (filename != chapter.ContentFileName) {
      filename = chapter.ContentFileName;
      final document = EpubCfiReader().chapterDocument(chapter);
      if (document != null) {
        final result = convertDocumentToElements(document);
        elmList = _removeAllDiv(result);
        return ChapterParagraphs(paragraphs: elmList, chapterNo: chapterIndex);
      }
    }
    chapterIndex++;
    return null;
  });

  return paragraphs.toList();
}

class ParseParagraphsResult {
  ParseParagraphsResult(this.flatParagraphs, this.chapterIndexes);

  final List<Paragraph> flatParagraphs;
  final List<int> chapterIndexes;
}
