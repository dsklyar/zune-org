part of genre_list_widget;

const LIST_GAP = 26.0;

class GenreList extends StatefulWidget {
  const GenreList({
    super.key,
  });

  @override
  State<GenreList> createState() => _GenreListState();
}

class _GenreListState extends State<GenreList> {
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, UnmodifiableListView<GenreSummary>>(
      selector: (context, state) => state.allGenres,

      /// NOTE: Using custom over scroll wrapper to allow user long swipe
      ///       across the scroll container to return to the top/bottom
      ///       of the list.
      builder: (context, genres, child) => OverScrollWrapper(
        /// NOTE: Using ListView separated her in order to configure
        ///       spaced out list item vertical view.
        builder: (scrollController, scrollPhysics) => ListView.separated(
          // Over-scroll logic props derived from OverScrollWrapper
          controller: scrollController,
          physics: scrollPhysics,
          // Rest of ListView props:
          scrollDirection: Axis.vertical,
          padding: parent.CATEGORY_PADDING,
          itemCount: genres.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: LIST_GAP,
          ),
          itemBuilder: (context, index) => GenreListTile(
            genre: genres[index],
          ),
        ),
      ),
    );
  }
}
