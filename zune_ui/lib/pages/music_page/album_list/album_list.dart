part of album_list_widget;

typedef AlbumGroupMap = LinkedHashMap<String, List<AlbumSummary>>;

class AlbumList extends StatefulWidget {
  const AlbumList({
    super.key,
  });

  @override
  State<AlbumList> createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  void _onReturnTapHandler() {
    console.log("Should go back to album Grid");
    // final musicPlayerAnimationContext =
    //     parent.MusicPlayerAnimationProvider.of(context);

    // musicPlayerAnimationContext?.executeWith(() async {
    //   if (context.mounted) {
    //     // context.go(ApplicationRoute.home.route);
    //     console.log("Should go back to album Grid");
    //   }
    // });
  }

  /// NOTE: Album List view allows "jumping" to a specific album via
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
      ScrollController? scrollController, AlbumGroupMap albumGroupMap) {
    // SearchIndexConfig is by default an empty map
    if (scrollController == null) return;
    double offset = 0.0;
    SearchIndexConfig searchIndexConfiguration = {};

    for (final entry in albumGroupMap.entries) {
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
          offset, (acc, album) => acc + ALBUM_LIST_TILE_SIZE + ALBUM_LIST_GAP);
      const groupKeyHeight = ALBUM_SEARCH_INDEX_TILE_SIZE + ALBUM_LIST_GAP;

      offset = groupCollectionHeight + groupKeyHeight;
    }

    OverlaysProvider.of(context)?.setSearchTileConfig(searchIndexConfiguration);
  }

  List<AlbumListTileGroup> _generateAlbumGroups(
    UnmodifiableListView<AlbumSummary> albums, {
    ScrollController? scrollController,
  }) {
    AlbumGroupMap albumGroupMap = parent.generateItemMap(
      albums,
      (e) => parent.generateItemGroupKey(e.album_name),
    );

    // Generate search index configuration needed for "jumping" to a specific album via group keys
    _generateSearchIndexConfiguration(scrollController, albumGroupMap);

    return parent.generateItemListFromMap(
      albumGroupMap,
      (groupKey, item) => (groupKey: groupKey, album: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// NOT RIGHT, the menu wrapper needs to be around music categories when this happens.....
    /// Here you need to lerp from album location in the grid to location in the list
    return ListWrapper<UnmodifiableListView<AlbumSummary>, AlbumSummary,
        AlbumListTileGroup>(
      selector: (state) => state.allAlbums,
      itemBuilder: (context, albumGroup) =>
          AlbumListTile(albumGroup: albumGroup),
      itemsMiddleware: _generateAlbumGroups,
    );
  }
}
