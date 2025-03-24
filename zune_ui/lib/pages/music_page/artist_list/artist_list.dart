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
    List<ArtistSummary> artists, {
    ScrollController? scrollController,
  }) {
    LinkedHashMap<String, List<ArtistSummary>> artistGroupMap =
        parent.generateItemMap(
      artists,
      (e) => parent.generateItemGroupKey(e.artist_name),
    );

    if (scrollController != null) {
      /// NOTE: This provider exposes all of the overlays in the app.
      final overlaysProvider = OverlaysProvider.of(context);
      SearchIndexConfig searchIndexConfiguration = {};
      double offset = 0.0;
      for (final entry in artistGroupMap.entries) {
        final currentOffset = offset;
        console.log("Print me: $currentOffset ${entry.key}");
        searchIndexConfiguration.putIfAbsent(
          entry.key,
          () => () async {
            await scrollController.animateTo(
              currentOffset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            );
          },
        );
        final collectionHeight =
            entry.value.fold(offset, (acc, artist) => acc + 44 + 26);
        const groupKeyHeight = 56 + 26;
        offset = collectionHeight + groupKeyHeight;
      }

      overlaysProvider?.setSearchTileConfig(searchIndexConfiguration);
    }
    return parent.generateItemListFromMap(
      artistGroupMap,
      (groupKey, item) => (groupKey: groupKey, artist: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<ArtistSummary>, ArtistSummary,
        ArtistListTileGroup>(
      selector: (state) => state.allArtists,
      itemBuilder: (context, artistGroup) =>
          ArtistListTile(artistGroup: artistGroup),
      itemsMiddleware: _generateArtistGroups,
    );
  }
}
