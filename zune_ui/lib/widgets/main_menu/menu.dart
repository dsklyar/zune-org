import 'package:flutter/widgets.dart';
import 'item.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // Disable scrollbar, but let scrolling
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: const [
          SizedBox(
            height: 64,
          ),
          MenuItem(
            text: 'music',
            hasIcon: true,
            subTextItems: [
              'songs',
              'genres',
              'albums',
              'artists',
              'playlists',
              'custom',
            ],
          ),
          MenuItem(
            text: 'playlists',
          ),
          MenuItem(text: 'podcasts'),
          MenuItem(text: 'videos'),
          MenuItem(text: 'radio'),
          MenuItem(text: 'marketplace'),
          MenuItem(text: 'social'),
          MenuItem(text: 'internet'),
          MenuItem(text: 'settings'),
          SizedBox(
            height: 64,
          )
        ],
      ),
    );
  }
}
