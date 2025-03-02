import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/pages/music_page/index.dart';
import 'package:zune_ui/pages/overlays_page/index.dart';
import 'package:zune_ui/pages/player_page/index.dart';
import 'package:zune_ui/providers/global_state/index.dart';
import 'package:zune_ui/providers/scroll_state/scroll_state.dart';
import 'package:zune_ui/pages/home_page/page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:go_router/go_router.dart';
import 'package:rinf/rinf.dart';
import 'package:zune_ui/widgets/custom/route_utils.dart';
import 'package:zune_ui/widgets/window_bar/index.dart';
import './messages/all.dart';

const initialSize = Size(272, 480);
const isDebug = kDebugMode;

final _router = GoRouter(
  routes: [
    ShellRoute(
      /// NOTE: Adds a Overlays wrapper here to support all overlays
      builder: (context, state, child) => OverlaysPage(
        size: initialSize,
        child: child,
      ),
      routes: [
        GoRoute(
          path: ApplicationRoute.home.route,
          builder: (context, state) => const HomePage(
            size: initialSize,
          ),
        ),
        GoRoute(
          path: ApplicationRoute.player.route,
          builder: (context, state) => const PlayerPage(
            size: initialSize,
          ),
        ),
        GoRoute(
          path: ApplicationRoute.music.route,
          builder: (context, state) {
            return MusicPageWrapped(
              size: initialSize,

              /// NOTE: For some reason Flutter inspector re-runs these routes
              ///       and the extra returns as null which before returned shrink box.
              ///       In future it is better to provide a default like so:
              startingOffset: state.extra as Offset? ?? Offset.zero,
            );
          },
        ),
      ],
    )
  ],
);

void main() async {
  await initializeRust(assignRustSignal);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ScrollStateModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => GlobalModalState(),
        ),
      ],
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: MyApp(),
      ),
    ),
  );

  doWhenWindowReady(() {
    appWindow.maxSize = initialSize;
    appWindow.minSize = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: initialSize.width,
      height: initialSize.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          WidgetsApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            color: const Color.fromARGB(255, 0, 0, 0),
            textStyle: const TextStyle(
              // Classic Zune Font :)
              fontFamily: 'Zegoe UI',
            ),
          ),
          const WindowBar(),
        ],
      ),
    );
  }
}
