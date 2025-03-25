part of track_list_widget;

typedef TrackGroupMap = LinkedHashMap<String, List<TrackSummary>>;

class TrackList extends StatefulWidget {
  const TrackList({
    super.key,
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  /// NOTE: Track List view allows "jumping" to a specific track via
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
      ScrollController? scrollController, TrackGroupMap trackGroupMap) {
    // SearchIndexConfig is by default an empty map
    if (scrollController == null) return;

    double offset = 0.0;
    SearchIndexConfig searchIndexConfiguration = {};

    for (final entry in trackGroupMap.entries) {
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
      final groupCollectionHeight = entry.value.fold(
          offset, (acc, artist) => acc + TRACK_LIST_TILE_SIZE + TRACK_LIST_GAP);
      const groupKeyHeight = TRACK_SEARCH_INDEX_TILE_SIZE + TRACK_LIST_GAP;

      offset = groupCollectionHeight + groupKeyHeight;
    }

    OverlaysProvider.of(context)?.setSearchTileConfig(searchIndexConfiguration);
  }

  /// NOTE: This method is responsible for generating track groups which
  ///       represent either a group key such as albums sorted under letter "a"
  ///       OR the actual track entry. Both are rendered by TrackGroupTile.
  ///
  ///       There are two ways to generate group which specified in the utils:
  ///       1. One shot method generateItemGroups which groups generateItemMap & generateItemListFromMap
  ///       2. Use generateItemMap & generateItemListFromMap to fit search index configuration generation
  List<TrackListTileGroup> _generateTrackGroups(
    List<TrackSummary> artists, {
    ScrollController? scrollController,
  }) {
    TrackGroupMap trackGroupMap = parent.generateItemMap(
      artists,
      (e) => parent.generateItemGroupKey(e.track_name),
    );

    _generateSearchIndexConfiguration(scrollController, trackGroupMap);

    return parent.generateItemListFromMap(
      trackGroupMap,
      (groupKey, item) => (groupKey: groupKey, track: item),
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
    return ListWrapper<UnmodifiableListView<TrackSummary>, TrackSummary,
        TrackListTileGroup>(
      listGap: TRACK_LIST_GAP,
      selector: (state) => state.allTracks,
      itemBuilder: (context, trackGroup) =>
          TrackListTile(trackGroup: trackGroup),
      itemsMiddleware: _generateTrackGroups,
    );
  }
}
