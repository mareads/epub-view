import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:epub_view/src/data/epub_parser.dart';
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:epub_view/src/data/models/paragraph.dart';
import 'package:epub_view/src/data/setting/src/epub_font_family.dart';
import 'package:epub_view/src/data/setting/src/epub_font_size.dart';
import 'package:epub_view/src/data/setting/src/epub_theme_mode.dart';
import 'package:epub_view/src/providers/cubits/reader_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'widgets/app_bar.dart';
import 'widgets/theme_setting.dart';
import 'widgets/toolbar.dart';

export 'package:epubx/epubx.dart' hide Image;
export 'package:hydrated_bloc/hydrated_bloc.dart';
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
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.builders = const EpubViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ),
    this.shrinkWrap = false,
    this.enableNavigationBar = true,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;
  final bool shrinkWrap;
  final bool enableNavigationBar;

  final void Function(EpubChapterViewValue? value)? onChapterChanged;

  /// Called when a document is loaded
  final void Function(EpubBook document)? onDocumentLoaded;

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
  List<Paragraph> _paragraphs = [];
  EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  final _chapterIndexes = <int>[];

  // Theme/Setting and Progress-Bar
  bool isShowNavigationBar = true;
  bool isShowThemeSetting = false;
  bool isShowToc = false;

  late final AnimationController _appBarAnimationController;
  late final Animation<double> _appBarAnimation;
  late AnimationController _tocAnimationController;
  late Animation<Offset> _tocAnimation;
  late final AnimationController _themeSettingAnimationController;
  late final Animation<double> _themeSettingAnimation;
  late StreamController<int> pageNumberController;

  EpubController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
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

    _tocAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _tocAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _tocAnimationController,
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

  @override
  void dispose() {
    _itemPositionListener!.itemPositions.removeListener(_changeListener);
    _controller._detach();
    _appBarAnimationController.dispose();
    _tocAnimationController.dispose();
    _themeSettingAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _init() async {
    if (_controller.isBookLoaded.value) {
      return true;
    }
    _chapters = parseChapters(_controller._document!);
    final parseParagraphsResult = parseParagraphs(_chapters, _controller._document!.Content);
    _paragraphs = parseParagraphsResult.flatParagraphs;
    _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);

    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: _controller.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener!.itemPositions.addListener(_changeListener);
    _controller.isBookLoaded.value = true;

    return true;
  }

  void _changeListener() {
    if (_paragraphs.isEmpty || _itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener!.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    final paragraphIndex = _getParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
    _controller.currentValueListenable.value = _currentValue;
    widget.onChapterChanged?.call(_currentValue);
  }

  void _gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final index = _epubCfiReader?.paragraphIndexByCfiFragment;

    if (index == null) {
      return;
    }

    _itemScrollController?.scrollTo(
      index: index,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }

  void _onLinkPressed(String href) {
    if (href.contains('://')) {
      widget.onExternalLinkPressed?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    String? hrefIdRef;
    String? hrefFileName;

    if (href.contains('#')) {
      final dividedHref = href.split('#');
      if (dividedHref.length == 1) {
        hrefIdRef = href;
      } else {
        hrefFileName = dividedHref[0];
        hrefIdRef = dividedHref[1];
      }
    } else {
      hrefFileName = href;
    }

    if (hrefIdRef == null) {
      final chapter = _chapterByFileName(hrefFileName);
      if (chapter != null) {
        final cfi = _epubCfiReader?.generateCfiChapter(
          book: _controller._document,
          chapter: chapter,
          additional: ['/4/2'],
        );

        _gotoEpubCfi(cfi);
      }
      return;
    } else {
      final paragraph = _paragraphByIdRef(hrefIdRef);
      final chapter = paragraph != null ? _chapters[paragraph.chapterIndex] : null;

      if (chapter != null && paragraph != null) {
        final paragraphIndex = _epubCfiReader?.getParagraphIndexByElement(paragraph.element);
        final cfi = _epubCfiReader?.generateCfi(
          book: _controller._document,
          chapter: chapter,
          paragraphIndex: paragraphIndex,
        );

        _gotoEpubCfi(cfi);
      }

      return;
    }
  }

  void _toggleToc() {
    setState(() {
      isShowToc = !isShowToc;
      if (isShowThemeSetting) isShowThemeSetting = false;
    });
    isShowToc ? _tocAnimationController.forward() : _tocAnimationController.reverse();
  }

  void _toggleThemeSetting() {
    setState(() {
      isShowThemeSetting = !isShowThemeSetting;
      if (isShowToc) isShowToc = false;
    });
    isShowThemeSetting
        ? _themeSettingAnimationController.forward()
        : _themeSettingAnimationController.reverse();
  }

  void _toggleToolOrAppBar() => isShowNavigationBar ? _hideAppBar() : _showAppBar();

  void _showAppBar() {
    setState(() => isShowNavigationBar = true);
    _appBarAnimationController.reverse();
  }

  void _hideAppBar() {
    setState(() => isShowNavigationBar = false);
    _appBarAnimationController.forward();
  }

  Paragraph? _paragraphByIdRef(String idRef) => _paragraphs.firstWhereOrNull((paragraph) {
        if (paragraph.element.id == idRef) {
          return true;
        }

        return paragraph.element.children.isNotEmpty && paragraph.element.children[0].id == idRef;
      });

  EpubChapter? _chapterByFileName(String? fileName) => _chapters.firstWhereOrNull((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName!.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      });

  int _getChapterIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );
    final index = posIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
  }

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
    List<Paragraph> paragraphs,
    int index,
    int chapterIndex,
    int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
  ) {
    if (paragraphs.isEmpty) {
      return Container();
    }

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
      builder: (_, state) {
        return Column(
          children: <Widget>[
            if (chapterIndex >= 0 && paragraphIndex == 0)
              builders.chapterDividerBuilder(chapters[chapterIndex]),
            Html(
              data: paragraphs[index].element.outerHtml,
              onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
              style: {
                'html': Style(
                  padding: options.paragraphPadding as EdgeInsets?,
                  lineHeight: LineHeight(state.lineHeight.value),
                ).merge(Style.fromTextStyle(
                  TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: state.fontFamily.family,
                    fontSize:
                        state.fontFamily.isJsJindara ? state.fontSize.dataJs : state.fontSize.data,
                    color: state.themeMode.data.textColor,
                  ),
                )),
              },
              customRenders: {
                tagMatcher('img'): CustomRender.widget(widget: (context, buildChildren) {
                  final url = context.tree.element!.attributes['src']!.replaceAll('../', '');
                  return Image(
                    image: MemoryImage(
                      Uint8List.fromList(
                        document.Content!.Images![url]!.Content!,
                      ),
                    ),
                  );
                }),
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context) {
    return ScrollablePositionedList.builder(
      shrinkWrap: widget.shrinkWrap,
      initialScrollIndex: _epubCfiReader!.paragraphIndexByCfiFragment ?? 0,
      itemCount: _paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: (BuildContext context, int index) {
        return widget.builders.chapterBuilder(
          context,
          widget.builders,
          widget.controller._document!,
          _chapters,
          _paragraphs,
          index,
          _getChapterIndexBy(positionIndex: index),
          _getParagraphIndexBy(positionIndex: index),
          _onLinkPressed,
        );
      },
    );
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
    if (widget.enableNavigationBar) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ReaderSettingCubit()),
        ],
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _toggleToolOrAppBar,
                // onTap: () {},
                child: BlocBuilder<ReaderSettingCubit, ReaderSettingState>(
                  builder: (__, state) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          top: 0,
                          child: ColoredBox(
                            color: state.themeMode.data.backgroundColor,
                            child: widget.builders.builder(
                              context,
                              widget.builders,
                              _controller.loadingState.value,
                              _buildLoaded,
                              _loadingError,
                            ),
                          ),
                        ),
                        if (isShowToc || isShowThemeSetting)
                          InkWell(
                            onTap: isShowToc ? _toggleToc : _toggleThemeSetting,
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black.withOpacity(.3),
                            ),
                          )
                      ],
                    );
                  },
                ),
              ),
              if (isShowNavigationBar) ...[
                EpubAppBar(
                  isOpenToc: isShowToc,
                  isOpenThemeSetting: isShowThemeSetting,
                  animation: _appBarAnimation,
                  onTapToc: _toggleToc,
                  onTapThemeSetting: _toggleThemeSetting,
                ),
                EpubToolbar(
                  animation: _appBarAnimation,
                  onPrevious: () {},
                  onNext: () {},
                  pageNumberController: pageNumberController,
                ),
              ],
              if (isShowThemeSetting) ThemeSettingPanel(animation: _themeSettingAnimation),
            ],
          ),
        ),
      );
    }

    return widget.builders.builder(
      context,
      widget.builders,
      _controller.loadingState.value,
      _buildLoaded,
      _loadingError,
    );
  }
}
