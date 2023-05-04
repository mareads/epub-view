import 'package:epub_view/epub_view.dart';
import 'package:epub_view_example/bloc/epub_manager_bloc.dart';
import 'package:epub_view_example/epub_list.dart';
import 'package:epub_view_example/service/hive/hive_service.dart';
import 'package:epub_view_example/service/local_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EpubController.initialize();
  await HiveService().initialize();
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
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;

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
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => EpubManagerBloc(),
        child: MaterialApp(
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
        ),
      );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
        // body: EpubView(
        //   builders: EpubViewBuilders<DefaultBuilderOptions>(
        //       options: const DefaultBuilderOptions(
        //         textStyle: TextStyle(
        //             fontSize: 18, fontWeight: FontWeight.w300, height: 1.5),
        //       ),
        //       chapterDividerBuilder: (_) => const Divider(),
        //       loaderBuilder: (ctx) {
        //         return const CircularProgressIndicator(
        //           color: Colors.blue,
        //         );
        //       }),
        //   controller: _epubReaderController,
        // ),
        body: BlocBuilder<EpubManagerBloc, EpubManagerState>(
          bloc: context.read<EpubManagerBloc>()..add(FetchEpubBooksEvent()),
          builder: (_, EpubManagerState state) {
            if (state.status.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status.isSuccess && state.ePubs.isEmpty) {
              return const SizedBox.shrink();
            }

            return EpubListScreen(
              mapPercentDownload: state.downloadPercent,
              mapPercentDelete: state.removePercent,
              data: state.ePubs,
            );
          },
        ),
      );
}
