import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/providers/scroll_state/scroll_state.dart';
import 'package:zune_ui/widgets/home_page/page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

const initialSize = Size(272, 480);
const isDebug = kDebugMode;
// const isDebug = false;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ScrollStateModel(),
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
      child: Column(
        children: [
          if (isDebug)
            Container(
              color: const Color.fromARGB(255, 255, 188, 4),
              child: WindowTitleBarBox(child: MoveWindow()),
            ),
          const Expanded(
            child: AnimatedHomePage(
              size: initialSize,
              isDebug: isDebug,
            ),
          ),
        ],
      ),
    );
  }
}
