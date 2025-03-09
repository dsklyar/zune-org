part of genre_list_widget;

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
      builder: (context, genres, child) {
        return ListView.separated(
          scrollDirection: Axis.vertical,
          padding: parent.CATEGORY_PADDING,
          itemCount: genres.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) => GenreListTile(genre: genres[index]),
        );
      },
    );
  }
}
