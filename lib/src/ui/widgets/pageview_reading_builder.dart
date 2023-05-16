import 'package:flutter/material.dart';

class PageViewReadingBuilder extends StatefulWidget {
  final int initialPage;
  final void Function()? pageViewListener;
  final void Function(PageController pageController)? onMount;
  final Widget Function(BuildContext context, PageController pageController)
      builder;
  const PageViewReadingBuilder(
      {Key? key,
      this.pageViewListener,
      required this.initialPage,
      required this.builder,
      this.onMount})
      : super(key: key);

  @override
  State<PageViewReadingBuilder> createState() => _PageViewWrapperState();
}

class _PageViewWrapperState extends State<PageViewReadingBuilder> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialPage);

    if (widget.onMount != null) {
      widget.onMount!(_pageController);
    }

    if (widget.pageViewListener != null) {
      _pageController.addListener(widget.pageViewListener!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pageViewListener!();
    });

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _pageController);
  }
}
