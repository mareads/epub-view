import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:epub_view/epub_view.dart' hide Image;
import 'package:epub_view/src/data/models/chapter_paragraphs.dart';
import 'package:epub_view/src/models/horizontal_paragraph.dart';
import 'package:epub_view/src/ui/reader_section.dart';
import 'package:epub_view/src/ui/widgets/epub_contents.dart';
import 'package:epub_view/src/ui/widgets/pageview_reading_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:epub_view/src/data/epub_parser.dart';
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:epub_view/src/data/setting/src/epub_font_family.dart';
import 'package:epub_view/src/data/setting/src/epub_font_size.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/reading_progress.dart';
import '../models/reading_setting.dart';
import 'widgets/app_bar.dart';
import 'widgets/theme_setting.dart';
import 'widgets/toolbar.dart';

export 'package:epubx/epubx.dart' hide Image;
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:equatable/equatable.dart';
export 'package:path_provider/path_provider.dart';

export 'widgets/app_bar.dart';
export 'widgets/theme_setting.dart';
export 'widgets/toolbar.dart';

part '../epub_controller.dart';

part '../helpers/epub_view_builders.dart';

const _minTrailingEdge = 0.55;
const _minLeadingEdge = -0.05;

typedef ExternalLinkPressed = void Function(String href);

class EpubView extends StatefulWidget {
  const EpubView({
    required this.controller,
    this.onExternalLinkPressed,
    this.initReadingProgress,
    this.initReadingSettings,
    this.isComicMode = false,
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.chapterNameFontSize = 1.5,
    this.onEpubExit,
    this.onDocumentError,
    this.builders = const EpubViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ),
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ReadingProgress? initReadingProgress;
  final ReadingSettings? initReadingSettings;
  final ExternalLinkPressed? onExternalLinkPressed;
  final bool shrinkWrap;

  final void Function(EpubChapterViewValue? value)? onChapterChanged;

  /// Called when a document is loaded
  final void Function(EpubBook document)? onDocumentLoaded;

  /// Chapter name [h1] font size
  final double chapterNameFontSize;

  /// Comic Mode is image continually connected together with no spacing in vertical view mode
  final bool isComicMode;

  /// Called when a Epub reader was disposed
  final Future<void> Function({
    required ReadingProgress readingProgress,
  })? onEpubExit;

  /// Called when a document loading error
  final void Function(Exception? error)? onDocumentError;

  /// Builders
  final EpubViewBuilders builders;

  @override
  State<EpubView> createState() => _EpubViewState();
}

class _EpubViewState extends State<EpubView> with TickerProviderStateMixin {
  Exception? _loadingError;

  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionListener;
  List<EpubChapter> _chapters = [];
  int _selectedChapterIndex = 0;
  bool _isStartOfFirstPage = true;
  List<ChapterParagraphs?> _chapterParagraphs = [];
  // int _paragraphsProgressList = [];
  // EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  final _chapterIndexes = <int>[];
  PageController? _pageController;
  final List<int> _chapterPageList = [0];
  // Theme/Setting and Progress-Bar

  late final AnimationController _appBarAnimationController;
  int? readingParagraphProgress;
  List<HorizontalParagraph>? horizontalParagraphs;
  ReadingSettings? readingSettings;
  late final Animation<double> _appBarAnimation;
  late final AnimationController _themeSettingAnimationController;
  late final Animation<double> _themeSettingAnimation;
  late StreamController<int> pageNumberController;

  EpubController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();

    _selectedChapterIndex =
        widget.initReadingProgress?.readingChapterProgress ?? 0;

    // print("initReadingProgress");
    // print(widget.initReadingProgress?.readingChapterProgress);

    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();

    _controller._attach(this);
    _controller.loadingState.addListener(() {
      switch (_controller.loadingState.value) {
        case EpubViewLoadingState.loading:
          break;
        case EpubViewLoadingState.success:
          widget.onDocumentLoaded?.call(_controller._document!);
          break;
        case EpubViewLoadingState.error:
          widget.onDocumentError?.call(_loadingError);
          break;
      }

      if (mounted) {
        setState(() {});
      }
    });

    _appBarAnimationController = animationController;
    _appBarAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.linear,
    ));

    _themeSettingAnimationController = animationController;
    _themeSettingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _themeSettingAnimationController,
      curve: Curves.linear,
    ));
    pageNumberController = StreamController.broadcast();
  }

  AnimationController get animationController => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

  Future<void> _handleOnDisposeReader() async {
    if (widget.onEpubExit != null) {
      await widget.onEpubExit!(
          // readingSettings: readingSettings ?? const ReadingSettings(),
          readingProgress: ReadingProgress(
              readingParagraphProgress: readingParagraphProgress,
              readingChapterProgress: _selectedChapterIndex));
    }
  }

  @override
  void dispose() {
    _itemPositionListener!.itemPositions.removeListener(_changeListener);
    _controller._detach();
    _appBarAnimationController.dispose();
    _themeSettingAnimationController.dispose();

    super.dispose();
  }

  Future<bool> _init() async {
    if (_controller.isBookLoaded.value) {
      return true;
    }

    _chapters = parseChapters(_controller._document!);
    compute<ParseChapterParagraphsInterface, List<ChapterParagraphs?>>(
            parseChapterParagraphs,
            ParseChapterParagraphsInterface(
                chapters: _chapters, content: _controller._document!.Content))
        .then((List<ChapterParagraphs?> value) {
      _chapterParagraphs = value;

      _itemPositionListener!.itemPositions.addListener(_changeListener);
      _controller.isBookLoaded.value = true;
      setState(() {});
    });

    // print("_chapterParagraphs");
    // print(_chapterParagraphs);
    // setState(() {
    //   _paragraphsProgressList = paragraphProgressList(paragraphs: _paragraphs);
    // });
    // _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);

    // _epubCfiReader = EpubCfiReader.parser(
    //   cfiInput: _controller.epubCfi,
    //   chapters: _chapters,
    //   paragraphs: _paragraphs,
    // );

    return true;
  }

  void _onPreviousChapter({required BuildContext ctx}) {
    final targetChapter = _selectedChapterIndex - 1;
    _onSelectChapter(chapterIndex: targetChapter, ctx: ctx);
  }

  void _onNextChapter({required BuildContext ctx}) {
    final targetChapter = _selectedChapterIndex + 1;
    _onSelectChapter(chapterIndex: targetChapter, ctx: ctx);
  }

  void _pageViewChangeListener() {
    final page = _pageController!.page!.floor();
    if (page == _pageController!.page) {
      // final chapterIndex = _chapterPageList.fold<int>(0, (all, sum) {
      //   int chapterIndex = page >= sum ? countIndex : all;
      //   countIndex++;
      //   return chapterIndex;
      // });
      // final position = _itemPositionListener!.itemPositions.value.first;

      _currentValue = EpubChapterViewValue(
        onHorizontalPageChange: onHorizontalPageChange,
        // chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
        chapterNumber: _selectedChapterIndex + 1,
        paragraphNumber: horizontalParagraphs![page].endingParagraphNumber!,
        position: ItemPosition(
            index: 1,
            itemLeadingEdge:
                horizontalParagraphs![page].leadingParagraphNumber!.toDouble(),
            itemTrailingEdge:
                horizontalParagraphs![page].endingParagraphNumber!.toDouble()),
        currentAllParagraphIndex: 0,
      );

      readingParagraphProgress =
          horizontalParagraphs?[page].leadingParagraphNumber;

      _controller.currentValueListenable.value = _currentValue;
      widget.onChapterChanged?.call(_currentValue);
    }
  }

  void _changeListener() {
    if (_chapterParagraphs.isEmpty ||
        _itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener!.itemPositions.value.first;
    final itemTrailingEdges = _itemPositionListener!.itemPositions.value
        .map((e) => e.itemTrailingEdge);
    final bottomScreenItemRatio = itemTrailingEdges.reduce((all, sum) {
      if (sum <= 1 && sum >= 0) {
        return max(all, sum);
      }
      return all;
    });
    final topScreenItemRatio = itemTrailingEdges.reduce((all, sum) {
      if (sum <= 1 && sum >= 0) {
        return min(all, sum);
      }
      return all;
    });
    final currentParagraphIndex = _itemPositionListener!.itemPositions.value
        .firstWhere(
            (element) => element.itemTrailingEdge == bottomScreenItemRatio)
        .index;
    final currentLeadingParagraphIndex = _itemPositionListener!
        .itemPositions.value
        .firstWhereOrNull(
            (element) => element.itemLeadingEdge == topScreenItemRatio)
        ?.index;
    // print(currentParagraphIndex);
    // final chapterIndex = _getChapterIndexBy(
    //   positionIndex: position.index,
    //   trailingEdge: position.itemTrailingEdge,
    //   leadingEdge: position.itemLeadingEdge,
    // );
    // final paragraphIndex = _getParagraphIndexBy(
    //   positionIndex: position.index,
    //   trailingEdge: position.itemTrailingEdge,
    //   leadingEdge: position.itemLeadingEdge,
    // );
    _currentValue = EpubChapterViewValue(
      onHorizontalPageChange: onHorizontalPageChange,
      // chapter: _selectedChapterIndex,
      chapterNumber: _selectedChapterIndex + 1,
      paragraphNumber: 1,
      currentAllParagraphIndex: currentParagraphIndex,
      position: position,
    );
    readingParagraphProgress = currentLeadingParagraphIndex;

    _controller.currentValueListenable.value = _currentValue;
    widget.onChapterChanged?.call(_currentValue);
  }

  void onHorizontalPageChange({required int chapterId}) {
    _pageController!.animateToPage(
      _chapterPageList[chapterId],
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<List<HorizontalParagraph>> paragraphsToPagesHandler(
      List<dom.Element> paragraphs,
      ReaderSettingState state,
      EdgeInsetsGeometry padding) async {
    /// reset for each run
    _chapterPageList.clear();
    _chapterPageList.add(0);

    final List<HorizontalParagraph> pages = [];
    final List<String> elements = [];
    HorizontalParagraph currentHorizontalParagraph = const HorizontalParagraph(
        leadingParagraphNumber: 0, endingParagraphNumber: null, elements: null);
    int currentChapter = 0;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double currentPageHeight = 0;
    final verticalSafeAreaPixel = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    final horizontalSafeAreaPixel = MediaQuery.of(context).padding.left +
        MediaQuery.of(context).padding.right;
    final paddingWidth = (padding.horizontal * 2) + horizontalSafeAreaPixel;

    final maxScreenHeight =
        screenHeight - verticalSafeAreaPixel - (padding.vertical * 2);

    double? paintHeight;
    final fontSize = state.fontFamily.isJsJindara
        ? state.fontSize.dataJs
        : state.fontSize.data;
    const indentCount = 8;
    final indentDartString = " " * indentCount;
    final indentHtmlString = "&nbsp;" * indentCount;
    int paragraphCount = 0;
    dom.Element? imageResizedElement;

    for (final paragraph in paragraphs) {
      if (paragraph.nodeType == dom.Node.ELEMENT_NODE) {
        // print("paragraph.text");
        // print(paragraph.text);
        // print("========================================");
        elementPagingHandler({required dom.Element currentParagraph}) async {
          // final isNewChapter = currentChapter != currentParagraph.chapterIndex;
          final isImageTag = currentParagraph.localName == "img";
          if (isImageTag) {
            // print("IMAGE: Paragraph");
            Completer<Size> completer = Completer();
            final url =
                currentParagraph.attributes["src"]!.replaceAll('../', '');

            Image image = Image(
              image: MemoryImage(
                Uint8List.fromList(
                  widget.controller._document!.Content!.Images![url]!.Content!,
                ),
              ),
            );
            image.image.resolve(const ImageConfiguration()).addListener(
              ImageStreamListener(
                (ImageInfo image, bool synchronousCall) {
                  var myImage = image.image;
                  Size size =
                      Size(myImage.width.toDouble(), myImage.height.toDouble());
                  completer.complete(size);
                },
              ),
            );
            final Size imageSize = await completer.future;
            if (imageSize.width > screenWidth - paddingWidth) {
              final diffRatio =
                  (imageSize.width - (screenWidth - paddingWidth)) /
                      imageSize.width;
              paintHeight =
                  (imageSize.height - (imageSize.height * diffRatio)) +
                      fontSize * 2;
            } else {
              // print("else : imageSize.height");
              // print(imageSize.height);
              paintHeight = imageSize.height + fontSize * 2;
            }
            if (paintHeight! > maxScreenHeight) {
              // print("paintHeight! > maxScreenHeight");
              imageResizedElement = dom.Element.html(currentParagraph.outerHtml
                  .replaceFirst('<img ',
                      "<img style='height: ${maxScreenHeight - 100}px;object-fit: contain;'"));
              paintHeight = maxScreenHeight - 100;
              // print("image paintHeight! $paintHeight");
            }
          } else {
            final String text = currentParagraph.text.trim();
            // inspect("--------------------------------");
            // inspect("TEXT: Paragraph");
            // inspect(text);
            // inspect("paragraph.element");
            // inspect(paragraph.element);
            if (text.isNotEmpty) {
              final TextSpan span = TextSpan(
                // text: isNewChapter ? text : "$indentDartString$text",
                text: text,
                style: TextStyle(
                  height: state.lineHeight.value,
                  fontWeight: FontWeight.w300,
                  fontFamily: state.fontFamily.family,
                  fontSize: currentParagraph.localName == "h1"
                      ? fontSize * 2
                      : fontSize,
                  color: state.themeMode.data.textColor,
                ),
              );
              final TextPainter painter = TextPainter(
                text: span,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
              );

              painter.layout(maxWidth: screenWidth - paddingWidth);
              // print("--------");
              // print("text");
              // print(span.text);
              // print("painter lines");
              // print(painter.computeLineMetrics().length);
              // print("currentPageHeight");
              // print(currentPageHeight);
              // print("maxScreenHeight");
              // print(maxScreenHeight);
              // print("--------");

              /// add paragraph margin spacing to calculate formular
              paintHeight = painter.height + fontSize * 1.5;
            } else {
              paintHeight = fontSize + fontSize * 1.5;
            }
          }
          // print("paintHeight");
          // print(paintHeight);
          // print("currentParagraph.text");
          // print(currentParagraph.element.text);

          final pageHeightNew = currentPageHeight + paintHeight!;

          /// Paragraph Cutting section with recursively mechanism
          if (pageHeightNew > maxScreenHeight) {
            final overflowHeight = pageHeightNew - maxScreenHeight;

            // print("overflowHeight");
            // print(overflowHeight);
            // print("paintHeight");
            // print(paintHeight);

            final newFitHeightRatio = (1 - (overflowHeight / paintHeight!));
            // print("newFitHeightRatio");
            // print(newFitHeightRatio);
            // print("overflowHeight");
            // print(overflowHeight);
            // print("pageHeightNew");
            // print(pageHeightNew);
            // print("maxScreenHeight");
            // print(maxScreenHeight);
            // print("paintHeight");
            // print(paintHeight);
            // print("currentPageHeight");
            // print(currentPageHeight);
            final cutIndex =
                (currentParagraph.text.length * newFitHeightRatio).floor();

            final cutWithSpaceIndex =
                currentParagraph.text.substring(0, cutIndex).lastIndexOf(" ");

            // print("currentParagraph.text");
            // print(currentParagraph.text);
            // print("cutWithSpaceIndex");
            // print(cutWithSpaceIndex);

            if (cutWithSpaceIndex == -1 && elements.isNotEmpty) {
              pages.add(currentHorizontalParagraph.copyWith(
                  endingParagraphNumber: paragraphCount <
                          currentHorizontalParagraph.leadingParagraphNumber!
                      ? paragraphCount + 1
                      : paragraphCount,
                  elements: dom.Element.html(
                      '<div>${List.from(elements).reduce((all, sum) => all + sum)}</div>')));
              elements.clear();
              currentHorizontalParagraph = HorizontalParagraph(
                  leadingParagraphNumber: paragraphCount + 1);
              currentPageHeight = 0;
              await elementPagingHandler(currentParagraph: currentParagraph);
              return;
            }

            final newFitParagraph = dom.Element.html(
                '<p>${currentParagraph.text.substring(0, cutWithSpaceIndex + 1)}</p>');
            final nextFitParagraph = dom.Element.html(
                '<p>${currentParagraph.text.substring(cutWithSpaceIndex + 1, currentParagraph.text.isNotEmpty ? currentParagraph.text.length : 0)}</p>');
            // debugger();

            // print("currentParagraph.text");
            // print(currentParagraph.text);
            // print("newFitHeightRatio");
            // print(newFitHeightRatio);
            // print("newFitParagraph");
            // print(newFitParagraph.text);
            // print("nextFitParagraph");
            // print(nextFitParagraph.text);

            if (newFitParagraph.text.isEmpty) {
              elements.add(imageResizedElement?.outerHtml ??
                  currentParagraph.outerHtml
                      .replaceFirst('<p>', '<p>$indentHtmlString'));
              currentPageHeight += paintHeight!;
              // currentChapter = currentParagraph.chapterIndex;
              imageResizedElement = null;
            } else {
              await elementPagingHandler(currentParagraph: newFitParagraph);

              await elementPagingHandler(currentParagraph: nextFitParagraph);
            }
          } else {
            elements.add(imageResizedElement?.outerHtml ??
                currentParagraph.outerHtml
                    .replaceFirst('<p>', '<p>$indentHtmlString'));
            currentPageHeight += paintHeight!;
            // currentChapter = currentParagraph.chapterIndex;
            imageResizedElement = null;

            // print("currentPageHeight");
            // print(currentPageHeight);
            // print("maxScreenHeight");
            // print(maxScreenHeight);

            // if (currentPageHeight / maxScreenHeight >= 0.5) {
            //   pages.add(currentHorizontalParagraph.copyWith(
            //       endingParagraphNumber: paragraphCount <
            //               currentHorizontalParagraph.leadingParagraphNumber!
            //           ? paragraphCount + 1
            //           : paragraphCount,
            //       elements: dom.Element.html(
            //           '<div>${List.from(elements).reduce((all, sum) => all + sum)}</div>')));
            //   elements.clear();
            //   currentHorizontalParagraph = HorizontalParagraph(
            //       leadingParagraphNumber: paragraphCount + 1);
            //   currentPageHeight = 0;
            // }
          }

          // debugPrint("paintHeight! > maxScreenHeight");
          // debugPrint(paintHeight.toString());
          // debugPrint(maxScreenHeight.toString());

          // elements.add(currentParagraph.element.outerHtml
          //     .replaceFirst('<p>', '<p>$indentHtmlString'));
          // currentPageHeight += paintHeight!;
          // currentChapter = currentParagraph.chapterIndex;
        }

        await elementPagingHandler(
          currentParagraph: paragraph,
        );
        paragraphCount++;
      }
    }
    if (elements.isNotEmpty) {
      pages.add(currentHorizontalParagraph.copyWith(
          endingParagraphNumber: paragraphCount,
          elements: dom.Element.html(
              '<div>${List.from(elements).reduce((all, sum) => all + sum)}</div>')));
      elements.clear();
      currentHorizontalParagraph =
          HorizontalParagraph(leadingParagraphNumber: paragraphCount + 1);
      currentPageHeight = 0;
    }

    // dev.inspect(pages);

    return pages;
  }

  // void _gotoEpubCfi(
  //   String? epubCfi, {
  //   double alignment = 0,
  //   Duration duration = const Duration(milliseconds: 250),
  //   Curve curve = Curves.linear,
  // }) {
  //   _epubCfiReader?.epubCfi = epubCfi;
  //   final index = _epubCfiReader?.paragraphIndexByCfiFragment;
  //
  //   if (index == null) {
  //     return;
  //   }
  //
  //   _itemScrollController?.scrollTo(
  //     index: index,
  //     duration: duration,
  //     alignment: alignment,
  //     curve: curve,
  //   );
  // }

  void _onLinkPressed(String href) {
    if (href.contains('://')) {
      widget.onExternalLinkPressed?.call(href);
      return;
    }

    // // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    // String? hrefIdRef;
    // String? hrefFileName;
    //
    // if (href.contains('#')) {
    //   final dividedHref = href.split('#');
    //   if (dividedHref.length == 1) {
    //     hrefIdRef = href;
    //   } else {
    //     hrefFileName = dividedHref[0];
    //     hrefIdRef = dividedHref[1];
    //   }
    // } else {
    //   hrefFileName = href;
    // }
    //
    // if (hrefIdRef == null) {
    //   final chapter = _chapterByFileName(hrefFileName);
    //   if (chapter != null) {
    //     final cfi = _epubCfiReader?.generateCfiChapter(
    //       book: _controller._document,
    //       chapter: chapter,
    //       additional: ['/4/2'],
    //     );
    //
    //     _gotoEpubCfi(cfi);
    //   }
    //   return;
    // } else {
    //   final paragraph = _paragraphByIdRef(hrefIdRef);
    //   final chapter =
    //       paragraph != null ? _chapters[paragraph.chapterIndex] : null;
    //
    //   if (chapter != null && paragraph != null) {
    //     final paragraphIndex =
    //         _epubCfiReader?.getParagraphIndexByElement(paragraph.element);
    //     final cfi = _epubCfiReader?.generateCfi(
    //       book: _controller._document,
    //       chapter: chapter,
    //       paragraphIndex: paragraphIndex,
    //     );
    //
    //     _gotoEpubCfi(cfi);
    //   }
    //
    //   return;
    // }
  }

  // Paragraph? _paragraphByIdRef(String idRef) =>
  //     _paragraphs.firstWhereOrNull((paragraph) {
  //       if (paragraph.element.id == idRef) {
  //         return true;
  //       }
  //
  //       return paragraph.element.children.isNotEmpty &&
  //           paragraph.element.children[0].id == idRef;
  //     });

  EpubChapter? _chapterByFileName(String? fileName) =>
      _chapters.firstWhereOrNull((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName!.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      });

  // int _getChapterIndexBy({
  //   required int positionIndex,
  //   double? trailingEdge,
  //   double? leadingEdge,
  // }) {
  //   final posIndex = _getAbsParagraphIndexBy(
  //     positionIndex: positionIndex,
  //     trailingEdge: trailingEdge,
  //     leadingEdge: leadingEdge,
  //   );
  //   final index = posIndex >= _chapterIndexes.last
  //       ? _chapterIndexes.length
  //       : _chapterIndexes.indexWhere((chapterIndex) {
  //           if (posIndex < chapterIndex) {
  //             return true;
  //           }
  //           return false;
  //         });
  //
  //   return index - 1;
  // }

  // int _getParagraphIndexBy({
  //   required int positionIndex,
  //   double? trailingEdge,
  //   double? leadingEdge,
  // }) {
  //   final posIndex = _getAbsParagraphIndexBy(
  //     positionIndex: positionIndex,
  //     trailingEdge: trailingEdge,
  //     leadingEdge: leadingEdge,
  //   );
  //
  //   final index = _getChapterIndexBy(positionIndex: posIndex);
  //
  //   if (index == -1) {
  //     return posIndex;
  //   }
  //
  //   return posIndex - _chapterIndexes[index];
  // }

  int _getAbsParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < _minTrailingEdge &&
        leadingEdge < _minLeadingEdge) {
      posIndex += 1;
    }

    return posIndex;
  }

  static Widget _chapterDividerBuilder(EpubChapter chapter) => Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0x24000000),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          chapter.Title ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static Widget _chapterBuilder(
    BuildContext context,
    EpubViewBuilders builders,
    EpubBook document,
    List<EpubChapter> chapters,
    List<dom.Element> paragraphs,
    int index,
    double chapterNameFontSize,
    bool isComicMode,

    // int chapterIndex,
    // int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
  ) {
    if (paragraphs.isEmpty) {
      return Container();
    }

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      buildWhen: (prev, cur) =>
          (prev.readerMode != cur.readerMode) ||
          (prev.lineHeight != cur.lineHeight) ||
          (prev.themeMode != cur.themeMode) ||
          (prev.fontFamily != cur.fontFamily) ||
          (prev.fontSize != cur.fontSize),
      builder: (_, state) {
        final headerFontStyle = Style().merge(Style.fromTextStyle(
          TextStyle(
            height: state.lineHeight.value,
            fontFamily: state.fontFamily.family,
            fontSize: (state.fontFamily.isJsJindara
                    ? state.fontSize.dataJs
                    : state.fontSize.data) *
                chapterNameFontSize,
            color: state.themeMode.data.textColor,
          ),
        ));
        if (isComicMode) {
          if (paragraphs[index].localName == 'img') {
            final url =
                paragraphs[index].attributes['src']!.replaceAll('../', '');
            return Image(
              image: MemoryImage(
                Uint8List.fromList(
                  document.Content!.Images![url]!.Content!,
                ),
              ),
            );
          }
          if (paragraphs[index].localName == 'br') {
            return const SizedBox(
              height: 0,
              width: 0,
            );
          }
        }

        return Html(
          data: paragraphs[index].outerHtml,
          onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
          style: {
            'h1': headerFontStyle,
            'h2': headerFontStyle,
            'h3': headerFontStyle,
            'h4': headerFontStyle,
            'html': Style(
              padding: options.paragraphPadding as EdgeInsets?,
            ).merge(Style.fromTextStyle(
              TextStyle(
                height: state.lineHeight.value,
                fontWeight: FontWeight.w300,
                fontFamily: state.fontFamily.family,
                fontSize: state.fontFamily.isJsJindara
                    ? state.fontSize.dataJs
                    : state.fontSize.data,
                color: state.themeMode.data.textColor,
              ),
            )),
          },
          customRenders: {
            // tagMatcher('p'):
            //     CustomRender.widget(widget: (context, buildChildren) {
            //   return Wrap(
            //     children: context.tree.children.map((e) {
            //       if (e is TextContentElement) {
            //         return Text(
            //           e.text ?? "",
            //           style: TextStyle(
            //             height: state.lineHeight.value,
            //             fontWeight: FontWeight.w300,
            //             fontFamily: state.fontFamily.family,
            //             fontSize: state.fontFamily.isJsJindara
            //                 ? state.fontSize.dataJs
            //                 : state.fontSize.data,
            //             color: state.themeMode.data.textColor,
            //           ),
            //         );
            //       } else {
            //         return const SizedBox(
            //           width: 0,
            //         );
            //       }
            //     }).toList(),
            //   );
            // }),
            tagMatcher('img'):
                CustomRender.widget(widget: (context, buildChildren) {
              final url = context.tree.element!.attributes['src']!
                  .replaceAll('../', '');
              return Image(
                image: MemoryImage(
                  Uint8List.fromList(
                    document.Content!.Images![url]!.Content!,
                  ),
                ),
              );
            }),
          },
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context) {
    return ScrollablePositionedList.builder(
      shrinkWrap: widget.shrinkWrap,
      initialScrollIndex: readingParagraphProgress ??
          widget.initReadingProgress?.readingParagraphProgress ??
          // _epubCfiReader!.paragraphIndexByCfiFragment ??
          0,
      itemCount: _chapterParagraphs[_selectedChapterIndex]!.paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: (BuildContext context, int index) {
        return widget.builders.chapterBuilder(
          context,
          widget.builders,
          widget.controller._document!,
          _chapters,
          _chapterParagraphs[_selectedChapterIndex]!.paragraphs,
          index,
          widget.chapterNameFontSize,
          widget.isComicMode,
          // _getChapterIndexBy(positionIndex: index),
          // _getParagraphIndexBy(positionIndex: index),
          _onLinkPressed,
        );
      },
    );
  }

  Widget _buildLoadedHorizontal(BuildContext ctx) {
    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      buildWhen: (prev, cur) =>
          (prev.readerMode != cur.readerMode) ||
          (prev.lineHeight != cur.lineHeight) ||
          (prev.themeMode != cur.themeMode) ||
          (prev.fontFamily != cur.fontFamily) ||
          (prev.fontSize != cur.fontSize),
      builder: (ctx, state) {
        final defaultBuilder =
            widget.builders as EpubViewBuilders<DefaultBuilderOptions>;
        DefaultBuilderOptions options = defaultBuilder.options;
        final padding = options.paragraphPadding;
        Future<List<HorizontalParagraph>> pages = paragraphsToPagesHandler(
            _chapterParagraphs[_selectedChapterIndex]!.paragraphs,
            state,
            padding);

        pages.then((value) {
          horizontalParagraphs = value;
        });
        final headerFontStyle = Style().merge(Style.fromTextStyle(
          TextStyle(
            height: state.lineHeight.value,
            fontFamily: state.fontFamily.family,
            fontSize: (state.fontFamily.isJsJindara
                    ? state.fontSize.dataJs
                    : state.fontSize.data) *
                widget.chapterNameFontSize,
            color: state.themeMode.data.textColor,
          ),
        ));
        return GestureDetector(
          onTapUp: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localOffset = box.globalToLocal(details.globalPosition);
            final x = localOffset.dx;
            final y = localOffset.dy;
            final tapableHeight = box.size.height / 2;
            final topTapableHeight = tapableHeight + box.size.height * 0.2;
            final bottomTapableHeight = tapableHeight - box.size.height * 0.2;
            if (y < topTapableHeight && y > bottomTapableHeight) {
              if (x < box.size.width / 2) {
                if (_pageController?.page == 0) {
                  _onSelectChapter(
                      chapterIndex: _selectedChapterIndex - 1,
                      ctx: ctx,
                      isLastPage: true);
                } else {
                  _pageController!.previousPage(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.linear);
                }
              } else {
                if (_pageController?.page == horizontalParagraphs!.length - 1) {
                  _onSelectChapter(
                      chapterIndex: _selectedChapterIndex + 1, ctx: ctx);
                } else {
                  _pageController!.nextPage(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.linear);
                }
              }
            } else {
              ctx.read<ReaderSettingCubit>().onToggleAppBar();
            }
          },
          child: FutureBuilder<List<HorizontalParagraph>>(
              future: pages,
              builder: (context, snap) {
                if (snap.data != null) {
                  final readingProgress = readingParagraphProgress ??
                      widget.initReadingProgress!.readingParagraphProgress ??
                      0;

                  final initialPage = horizontalParagraphs?.indexWhere(
                      (element) =>
                          readingProgress >= element.leadingParagraphNumber! &&
                          readingProgress <= element.endingParagraphNumber!);

                  if (!_isStartOfFirstPage) {
                    _pageController
                        ?.jumpToPage(horizontalParagraphs!.length - 1);
                  }

                  return PageViewReadingBuilder(
                      initialPage: initialPage!,
                      pageViewListener: _pageViewChangeListener,
                      onMount: (PageController pageController) {
                        _pageController = pageController;
                      },
                      builder: (BuildContext context,
                          PageController pageController) {
                        return PageView(
                          controller: _pageController,
                          children: snap.data!.map(
                            (element) {
                              return Padding(
                                padding: padding,
                                child: InteractiveViewer(
                                  minScale: 1,
                                  maxScale: 5,
                                  child: Html(
                                    data: element.elements?.outerHtml,
                                    // onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
                                    style: {
                                      'h1': headerFontStyle,
                                      'h2': headerFontStyle,
                                      'h3': headerFontStyle,
                                      'h4': headerFontStyle,
                                      'html': Style().merge(Style.fromTextStyle(
                                        TextStyle(
                                          height: state.lineHeight.value,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: state.fontFamily.family,
                                          fontSize: state.fontFamily.isJsJindara
                                              ? state.fontSize.dataJs
                                              : state.fontSize.data,
                                          color: state.themeMode.data.textColor,
                                        ),
                                      )),
                                    },

                                    customRenders: {
                                      // tagMatcher('p'): CustomRender.widget(
                                      //     widget: (context, buildChildren) {
                                      //   return Wrap(
                                      //     children:
                                      //         context.tree.children.map((e) {
                                      //       if (e is TextContentElement) {
                                      //         return Text(
                                      //           e.text ?? "",
                                      //           style: TextStyle(
                                      //             height:
                                      //                 state.lineHeight.value,
                                      //             fontWeight: FontWeight.w300,
                                      //             fontFamily:
                                      //                 state.fontFamily.family,
                                      //             fontSize: state.fontFamily
                                      //                     .isJsJindara
                                      //                 ? state.fontSize.dataJs
                                      //                 : state.fontSize.data,
                                      //             color: state.themeMode.data
                                      //                 .textColor,
                                      //           ),
                                      //         );
                                      //       } else {
                                      //         return const SizedBox(
                                      //           width: 0,
                                      //         );
                                      //       }
                                      //     }).toList(),
                                      //   );
                                      // }),
                                      // textContentElementMatcher():
                                      //     CustomRender.inlineSpan(inlineSpan:
                                      //         (context, buildChildren) {
                                      //   inspect("context.tree.element!.text");
                                      //   inspect(context.tree.element!.text);
                                      //   print(
                                      //       context.tree.element!.text.isEmpty);
                                      //   if (context
                                      //       .tree.element!.text.isEmpty) {
                                      //     return const WidgetSpan(
                                      //         child: SizedBox(
                                      //       height: 0,
                                      //       width: 0,
                                      //     ));
                                      //   }
                                      //
                                      //   return TextSpan(
                                      //       text: context.tree.element?.text,
                                      //       style: TextStyle(
                                      //         height: context
                                      //             .tree.style.lineHeight?.size,
                                      //         fontWeight:
                                      //             context.tree.style.fontWeight,
                                      //         fontFamily:
                                      //             context.tree.style.fontFamily,
                                      //         fontSize: context
                                      //             .tree.style.fontSize?.value,
                                      //         color: context.tree.style.color,
                                      //       ));
                                      // }),
                                      tagMatcher('img'): CustomRender.widget(
                                          widget: (context, buildChildren) {
                                        final url = context
                                            .tree.element!.attributes['src']!
                                            .replaceAll('../', '');
                                        return Center(
                                          child: Image(
                                            image: MemoryImage(
                                              Uint8List.fromList(
                                                widget
                                                    .controller
                                                    ._document!
                                                    .Content!
                                                    .Images![url]!
                                                    .Content!,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      // tagMatcher('wbr'):
                                      //     CustomRender.inlineSpan(inlineSpan:
                                      //         (context, buildChildren) {
                                      //   return const TextSpan(text: "\u200B");
                                      // }),
                                    },
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      });
                }

                return const Text("Loading...");
              }),
        );
      },
    );
    // return Container();
  }

  void _onSelectChapter(
      {required chapterIndex, required BuildContext ctx, bool? isLastPage}) {
    if (chapterIndex < 0 || chapterIndex > _chapterParagraphs.length - 1) {
      return;
    }
    setState(() {
      if (isLastPage != null && isLastPage) {
        _isStartOfFirstPage = false;
      } else {
        _isStartOfFirstPage = true;
      }
      _selectedChapterIndex = chapterIndex;
    });
    final readState = ctx.read<ReaderSettingCubit>().state;
    if (readState.readerMode.isHorizontal) {
      if (isLastPage != true) {
        _pageController?.jumpTo(0);
      }
      _pageViewChangeListener();
    } else {
      if (isLastPage != true) {
        _itemScrollController?.jumpTo(index: 0);
      }
      _changeListener();
    }
  }

  static Widget _builder(
    BuildContext context,
    EpubViewBuilders builders,
    EpubViewLoadingState state,
    WidgetBuilder loadedBuilder,
    Exception? loadingError,
  ) {
    final Widget content = () {
      switch (state) {
        case EpubViewLoadingState.loading:
          return KeyedSubtree(
            key: const Key('epubx.root.loading'),
            child: builders.loaderBuilder?.call(context) ?? const SizedBox(),
          );
        case EpubViewLoadingState.error:
          return KeyedSubtree(
            key: const Key('epubx.root.error'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: builders.errorBuilder?.call(context, loadingError!) ??
                  Center(child: Text(loadingError.toString())),
            ),
          );
        case EpubViewLoadingState.success:
          return KeyedSubtree(
            key: const Key('epubx.root.success'),
            child: loadedBuilder(context),
          );
      }
    }();

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return AnimatedSwitcher(
      duration: options.loaderSwitchDuration,
      transitionBuilder: options.transitionBuilder,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _chapterParagraphs.isNotEmpty
          ? MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ReaderSettingCubit()),
              ],
              child: BlocListener<ReaderSettingCubit, ReaderSettingState>(
                listener: (ctx, state) {
                  readingSettings = ReadingSettings(
                      readerMode: state.readerMode,
                      fontSize: state.fontSize,
                      fontFamily: state.fontFamily,
                      lineHeight: state.lineHeight,
                      themeMode: state.themeMode);
                },
                child: Stack(
                  children: [
                    /// App Bar Navigator controller
                    MultiBlocListener(
                      listeners: [
                        BlocListener<ReaderSettingCubit, ReaderSettingState>(
                            listenWhen: (prev, cur) =>
                                prev.isShowToc != cur.isShowToc,
                            listener: (ctx, state) {
                              if (state.isShowToc) {
                                _appBarAnimationController.reverse();
                              } else {
                                _appBarAnimationController.forward();
                              }
                            }),
                        BlocListener<ReaderSettingCubit, ReaderSettingState>(
                            listenWhen: (prev, cur) =>
                                prev.isShowSettingSection !=
                                cur.isShowSettingSection,
                            listener: (ctx, state) {
                              if (state.isShowSettingSection) {
                                _themeSettingAnimationController.forward();
                              } else {
                                _themeSettingAnimationController.reverse();
                              }
                            }),
                      ],
                      child: const SizedBox(),
                    ),
                    ReaderSection(
                      currentChapter: _chapterParagraphs.isNotEmpty
                          ? _chapterParagraphs[_selectedChapterIndex]
                          : null,
                      builders: widget.builders,
                      controller: _controller,
                      buildLoaded: _buildLoaded,
                      buildLoadedHorizontal: _buildLoadedHorizontal,
                      loadingError: _loadingError,
                    ),
                    EpubAppBar(
                      handleOnDisposeReader: _handleOnDisposeReader,
                      animation: _appBarAnimation,
                    ),

                    EpubToolbar(
                      animation: _appBarAnimation,
                      onPrevious: (context) {
                        _onPreviousChapter(ctx: context);
                      },
                      onNext: (context) {
                        _onNextChapter(ctx: context);
                      },
                    ),

                    BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
                        buildWhen: (prev, cur) =>
                            prev.isShowSettingSection !=
                            cur.isShowSettingSection,
                        builder: (context, state) {
                          if (state.isShowSettingSection) {
                            return ThemeSettingPanel(
                                animation: _themeSettingAnimation);
                          } else {
                            return const SizedBox();
                          }
                        }),

                    BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
                        buildWhen: (prev, cur) =>
                            prev.isShowChaptersSection !=
                            cur.isShowChaptersSection,
                        builder: (context, state) {
                          if (state.isShowChaptersSection) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: kToolbarHeight),
                              child: EpubViewContents(
                                  controller: _controller,
                                  onSelectChapter: _onSelectChapter),
                            );
                          }
                          return const SizedBox();
                        }),
                  ],
                ),
              ),
            )
          : widget.builders.loaderBuilder?.call(context) ??
              const CircularProgressIndicator(),
    );
  }
}
