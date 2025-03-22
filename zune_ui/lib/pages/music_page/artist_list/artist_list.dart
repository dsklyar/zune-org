part of artist_list_widget;

class ArtistList extends StatefulWidget {
  const ArtistList({
    super.key,
  });

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  List<ArtistListTileGroup> _generateArtistGroups(
          List<ArtistSummary> artists) =>
      parent.generateItemGroups<ArtistSummary, ArtistListTileGroup>(
        artists,
        (groupKey, item) => (groupKey: groupKey, artist: item),
        (e) => parent.generateItemGroupKey(e.artist_name),
      );

  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<ArtistSummary>, ArtistSummary,
        ArtistListTileGroup>(
      selector: (state) => state.allArtists,
      itemBuilder: (context, artistGroup) =>
          ArtistListTile(artistGroup: artistGroup),
      itemsReducer: _generateArtistGroups,
    );
  }
}
