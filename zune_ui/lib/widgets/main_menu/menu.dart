part of main_menu;

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(
      //   color: Color.fromARGB(123, 30, 248, 59),
      // ),
      child: ScrollConfiguration(
        // Disable scrollbar, but let scrolling
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: const [
            SizedBox(
              height: 42,
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
              ],
            ),
            MenuItem(
              text: 'videos',
            ),
            MenuItem(text: 'pictures', subTextItems: [
              'by folder',
              'by date',
            ]),
            MenuItem(text: 'radio'),
            // MenuItem(text: 'marketplace'),
            MenuItem(text: 'social'),
            MenuItem(text: 'internet'),
            MenuItem(text: 'settings'),
            SizedBox(
              height: 64,
            )
          ],
        ),
      ),
    );
  }
}
