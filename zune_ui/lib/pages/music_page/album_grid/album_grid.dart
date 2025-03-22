part of album_grid_widget;

class AlbumsGrid extends StatefulWidget {
  const AlbumsGrid({
    super.key,
  });

  @override
  State<AlbumsGrid> createState() => _AlbumsGridState();
}

class _AlbumsGridState extends State<AlbumsGrid> {
  List<AlbumGridTileGroup> _generateAlbumGroups(List<AlbumSummary> albums) =>
      parent.generateItemGroups<AlbumSummary, AlbumGridTileGroup>(
        albums,
        (groupKey, item) => (groupKey: groupKey, album: item),
        (e) => parent.generateItemGroupKey(e.album_name),
      );

  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, UnmodifiableListView<AlbumSummary>>(
      selector: (context, state) => state.allAlbums,
      builder: (context, albums, child) {
        final albumGroups = _generateAlbumGroups(albums);

        /// NOTE: Using ListView separated her in order to configure
        ///       spaced out list item vertical view.
        return OverScrollWrapper(
          /// NOTE: This should lazy load if there are many albums.
          builder: (scrollController, scrollPhysics) => GridView.builder(
            // Over scroll props:
            controller: scrollController,
            physics: scrollPhysics,
            // GridView props:
            padding: parent.CATEGORY_PADDING,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 24,
              childAspectRatio: 1,
            ),
            itemCount: albumGroups.length,
            itemBuilder: (context, index) => AlbumsGridTile(
              albumGroup: albumGroups[index],
            ),
          ),
        );
      },
    );
  }
}
