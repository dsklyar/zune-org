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
      color: Colors.transparent,
      child: ScrollConfiguration(
        // Disable scrollbar, but let scrolling
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            const SizedBox(
              height: 42,
            ),
            MenuItem(
              text: 'music',
              onTapHandler: (Offset target) => context.go(
                ApplicationRoute.music.route,
                extra: target,
              ),
              hasIcon: true,
              subTextItems: const [
                'songs',
                'genres',
                'albums',
                'artists',
                'playlists',
              ],
            ),
            const MenuItem(
              text: 'videos',
            ),
            const MenuItem(text: 'pictures', subTextItems: [
              'by folder',
              'by date',
            ]),
            const MenuItem(text: 'radio'),
            // const MenuItem(text: 'marketplace'),
            const MenuItem(text: 'social'),
            const MenuItem(text: 'internet'),
            const MenuItem(text: 'settings'),
            const SizedBox(
              height: 64,
            )
          ],
        ),
      ),
    );
  }
}
