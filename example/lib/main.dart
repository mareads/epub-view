import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EpubController.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  Brightness get platformBrightness =>
      MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .platformBrightness;

  void _setSystemUIOverlayStyle() {
    if (platformBrightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Epub demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scrollbarTheme: ScrollbarThemeData(
            crossAxisMargin: 2,
            mainAxisMargin: 0,
            minThumbLength: 20,
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(true),
            thumbColor: MaterialStateProperty.all(const Color(0xFF3f54d9)),
            radius: const Radius.circular(5),
            trackColor: MaterialStateProperty.all(const Color(0xfff4f4f7)),
            trackVisibility: MaterialStateProperty.all(true),
            trackBorderColor: MaterialStateProperty.all(Colors.transparent),
            interactive: true,
          ),
          colorScheme: const ColorScheme.light().copyWith(
            primary: const Color(0xFF3F54D9),
            secondary: const Color(0xFF3F54D9).withOpacity(.6),
            primaryContainer: const Color(0xFFffffff),
            background: const Color(0xff0c1135),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late EpubController _epubReaderController;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document: EpubDocument.openAsset('assets/185.epub'),
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(
        //   title: EpubViewActualChapter(
        //     controller: _epubReaderController,
        //     builder: (chapterValue) => Text(
        //       chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
        //       textAlign: TextAlign.start,
        //     ),
        //   ),
        //   actions: <Widget>[
        //     IconButton(
        //       icon: const Icon(Icons.save_alt),
        //       color: Colors.white,
        //       onPressed: () => _showCurrentEpubCfi(context),
        //     ),
        //   ],
        // ),
        // drawer: Drawer(
        //   child: EpubViewTableOfContents(controller: _epubReaderController),
        // ),
        body: EpubView(
          builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(
                paragraphPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                textStyle: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w300, height: 1.5),
              ),
              chapterDividerBuilder: (_) => const Divider(),
              loaderBuilder: (ctx) {
                return const CircularProgressIndicator(
                  color: Colors.blue,
                );
              }),
          controller: _epubReaderController,
        ),
      );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
