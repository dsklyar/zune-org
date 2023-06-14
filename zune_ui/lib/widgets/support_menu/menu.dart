import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/providers/scroll_state/scroll_state.dart';
import 'package:zune_ui/widgets/support_menu/styles.dart';

Widget currentAudio = Container(
  height: 192,
  width: 192,
  // decoration: BoxDecoration(
  //   shape: BoxShape.rectangle,
  //   border: Border.all(
  //     width: 1,
  //     color: const Color.fromARGB(255, 255, 255, 255),
  //   ),
  // ),
  child: Stack(
    children: [
      Image.asset('assets/images/album_cover.jpg'),
      Positioned(
        bottom: 0,
        child: Text(
          'around the fur'.toUpperCase(),
          style: Styles.albumTitle,
        ),
      )
    ],
  ),
);

Widget pinnedAudio = Container(
  height: 96, // 96 - 4 - 4 = 88
  width: 96, // 96 - 4 - 4 = 88
  decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      border: Border.all(
        width: 1,
        color: const Color.fromARGB(255, 255, 255, 255),
      )),
);

class SupportMenu extends StatelessWidget {
  const SupportMenu({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ScrollStateModel>(
      builder: (context, scrollState, child) => ScrollConfiguration(
        // Disable scrollbar, but let scrolling
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          controller: ScrollController(initialScrollOffset: 1000.0),
          key: scrollState.getSupportKey(),
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 64),
            SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Paused", style: Styles.tileText),
                currentAudio,
              ],
            ),
            SizedBox(height: 32),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pins", style: Styles.tileText),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    direction: Axis.horizontal,
                    children: [
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                      pinnedAudio,
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
