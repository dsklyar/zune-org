part of artist_list_widget;

typedef ArtistGroupMap = LinkedHashMap<String, List<ArtistSummary>>;

class ArtistList extends StatefulWidget {
  const ArtistList({
    super.key,
  });

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  /// NOTE: Artist List view allows "jumping" to a specific artist via
  ///       group keys rendered in the list.
  ///
  ///       This method is responsible for generating search index configuration map
  ///       which represents a group key e.g. letter "a" mapped to a function that
  ///       animated scroll controller to a location of the group key in the list.
  ///
  ///       Using pre-defined constant values to derive the group collection & key heights
  ///       because the list view wrapper is dynamically built. This might not be the best
  ///       solution to derive the search index configuration, perhaps a global solution
  ///       might be faster.
  void _generateSearchIndexConfiguration(
      ScrollController? scrollController, ArtistGroupMap artistGroupMap) {
    // SearchIndexConfig is by default an empty map
    if (scrollController == null) return;

    double offset = 0.0;
    SearchIndexConfig searchIndexConfiguration = {};

    for (final entry in artistGroupMap.entries) {
      // Since offset is a mutable closure, need to define a final value here
      final currentOffset = offset;
      searchIndexConfiguration.putIfAbsent(
        entry.key,
        () => () async => await scrollController.animateTo(
              currentOffset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            ),
      );

      // Derive group collection & key heights to compute offsets needed for animation
      final groupCollectionHeight = entry.value.fold(offset,
          (acc, artist) => acc + ARTIST_LIST_TILE_SIZE + ARTIST_LIST_GAP);
      const groupKeyHeight = ARTIST_SEARCH_INDEX_TILE_SIZE + ARTIST_LIST_GAP;

      offset = groupCollectionHeight + groupKeyHeight;
    }

    OverlaysProvider.of(context)?.setSearchTileConfig(searchIndexConfiguration);
  }

  /// NOTE: This method is responsible for generating artist groups which
  ///       represent either a group key such as albums sorted under letter "a"
  ///       OR the actual artist entry. Both are rendered by ArtistGroupTile.
  ///
  ///       There are two ways to generate group which specified in the utils:
  ///       1. One shot method generateItemGroups which groups generateItemMap & generateItemListFromMap
  ///       2. Use generateItemMap & generateItemListFromMap to fit search index configuration generation
  List<ArtistListTileGroup> _generateArtistGroups(
    List<ArtistSummary> artists, {
    ScrollController? scrollController,
  }) {
    ArtistGroupMap artistGroupMap = parent.generateItemMap(
      artists,
      (e) => parent.generateItemGroupKey(e.artist_name),
    );

    _generateSearchIndexConfiguration(scrollController, artistGroupMap);

    return parent.generateItemListFromMap(
      artistGroupMap,
      (groupKey, item) => (groupKey: groupKey, artist: item),
    );
  }

  @override
  void deactivate() {
    // Clear search tile config after the widget is deactivated
    // Prevent case where config is present and used for incorrect widget
    OverlaysProvider.of(context)?.setSearchTileConfig({});
    super.deactivate();
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
