part of artist_list_widget;

class ArtistList extends StatefulWidget {
  const ArtistList({
    super.key,
  });

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<ArtistSummary>, ArtistSummary>(
      selector: (state) => state.allArtists,
      itemBuilder: (context, artist) => ArtistListTile(artist: artist),
    );
  }
}
