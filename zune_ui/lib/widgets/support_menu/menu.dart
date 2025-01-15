part of support_menu;

class SupportMenu extends StatelessWidget {
  const SupportMenu({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
                    onClickHandler: (item) => context.go("/playing"),
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "Pins",
                    items: state.pinnedItems,
                    onClickHandler: state.updateCurrentlyPlaying,
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "History",
                    items: state.recentlyPlayedItems,
                    onClickHandler: state.updateCurrentlyPlaying,
                  );
                },
              ),
              Consumer<GlobalModalState>(
                builder: (context, state, child) {
                  return ItemsColumn(
                    title: "New",
                    items: state.newlyAddedItems,
                    onClickHandler: state.updateCurrentlyPlaying,
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
