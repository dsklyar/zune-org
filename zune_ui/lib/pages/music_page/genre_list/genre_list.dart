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
    return ListWrapper<UnmodifiableListView<GenreSummary>, GenreSummary>(
      selector: (state) => state.allGenres,
      itemBuilder: (context, genre) => GenreListTile(
        genre: genre,
      ),
    );
  }
}
