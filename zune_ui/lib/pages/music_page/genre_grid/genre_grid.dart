part of genre_grid_widget;

class GenreGrid extends StatefulWidget {
  const GenreGrid({
    super.key,
  });

  @override
  State<GenreGrid> createState() => _GenreGridState();
}

class _GenreGridState extends State<GenreGrid> {
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, UnmodifiableListView<GenreSummary>>(
      selector: (context, state) => state.allGenres,
      builder: (context, genres, child) {
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) => GenreGridTile(genre: genres[index]),
        );
      },
    );
  }
}
