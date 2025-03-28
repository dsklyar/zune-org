part of support_menu;

class SupportMenu extends StatelessWidget {
  const SupportMenu({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /// TODO: Need to figure out a way to specify what onclick does to other interactive items
    onItemClickHandler(GlobalModalState state) => (InteractiveItem item) {
          if (item is AlbumSummary) {
            state.updateCurrentlyPlaying(item);
            context.go(ApplicationRoute.player.route);
          }
        };

    return Container(
      // decoration: const BoxDecoration(
      //   color: Color.fromARGB(121, 238, 3, 81),
      // ),
      // TODO:
      // Cannot add padding or margin because it will clip the full screen
      // Need to use transform most likely
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
      child: Consumer<ScrollStateModel>(
        builder: (context, scrollState, child) => ScrollConfiguration(
          // Disable scrollbar, but let scrolling
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            controller: ScrollController(initialScrollOffset: -100.0),
            key: scrollState.getSupportKey(),
            scrollDirection: Axis.vertical,
            children: [
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return CurrentItem(
                    album: state.currentlyPlaying?.album,
                    isPlaying: state.isPlaying,
                    onClickHandler: (item) =>
                        context.go(ApplicationRoute.player.route),
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "Pins",
                    items: state.pinnedItems,
                    onClickHandler: onItemClickHandler(state),
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "History",
                    items: state.recentlyPlayedItems,
                    onClickHandler: onItemClickHandler(state),
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "New",
                    items: state.newlyAddedItems,
                    onClickHandler: onItemClickHandler(state),
                    isLast: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
