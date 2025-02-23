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
  @override
  void initState() {
    super.initState();
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
              height: 64,
            ),
            Selector<GlobalModalState, MusicCategoryType>(
              selector: (context, state) => state.lastSelectedCategory,
              builder: (context, selectedCategory, child) => MenuItem(
                text: 'music',
                onTapHandler: (Offset target) => context.go(
                  ApplicationRoute.music.route,
                  extra: target,
                ),
                hasIcon: true,
                subTextItems: MusicCategoryType.categoriesStartingAt(
                  type: selectedCategory,
                ),
              ),
            ),
            MenuItem(
              text: 'videos',
            ),
            MenuItem(text: 'pictures', subTextItems: const [
              'by folder',
              'by date',
            ]),
            MenuItem(text: 'radio'),
            //  MenuItem(text: 'marketplace'),
            MenuItem(text: 'social'),
            MenuItem(text: 'internet'),
            MenuItem(text: 'settings'),
            const SizedBox(
              height: 64,
            )
          ],
        ),
      ),
    );
  }
}
