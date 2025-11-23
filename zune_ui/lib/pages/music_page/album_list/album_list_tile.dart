part of album_list_widget;

typedef AlbumListTileGroup = ({String? groupKey, AlbumSummary? album});

class AlbumListTile extends StatelessWidget {
  final AlbumListTileGroup albumGroup;

  const AlbumListTile({
    super.key,
    required this.albumGroup,
  });

  Widget generateGroupKeyTile(BuildContext context, String groupKey) {
    /// NOTE: This provider exposes all of the overlays in the app.
    final overlaysProvider = OverlaysProvider.of(context);
    return SizedBox(
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
          child: SquareTile(
            size: ALBUM_LIST_TILE_SIZE,
            alignment: Alignment.bottomRight,
            noBorder: true,
            child: SquareTile(
              size: TileUtility.smallTileWidth,
              alignment: Alignment.bottomRight,
              textStyle: Styles.searchTileFont,
              text: albumGroup.groupKey!,
            ),
          ),
        ),
      ),
    );
  }

  Widget generateAlbumTile(BuildContext context, AlbumSummary album) {
    return ListItemWrapper<AlbumSummary>(
      data: album,
      height: ALBUM_LIST_TILE_SIZE,
      widgetConfigs: [
        // Album Cover
        (
          builder: (context, album) => Container(
                alignment: Alignment.centerLeft,
                child: SquareTile(
                  size: ALBUM_LIST_TILE_SIZE,
                  alignment: Alignment.bottomRight,
                  textStyle: Styles.albumTileFont,
                  background: album.album_cover,
                  text: album.album_cover != null
                      ? null
                      : album.album_name.toUpperCase(),
                ),
              ),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[0]!
        ),
        // Play Button
        (
          builder: (context, _) => const ListTilePlayButton(),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[1]!
        ),
        // Albums Title
        (
          builder: (context, album) => Text(
                album.album_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.albumTitleFont,
              ),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[2]!
        ),
        // Albums Artist
        (
          builder: (context, album) => Text(
                album.artist_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.albumArtistFont,
              ),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[3]!
        ),
        // Albums Songs
        (
          builder: (context, album) =>
              LazyAlbumTracksList(track_ids: album.track_ids),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[4]!
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return albumGroup.groupKey != null
        ? generateGroupKeyTile(context, albumGroup.groupKey!)
        : albumGroup.album != null
            ? generateAlbumTile(context, albumGroup.album!)
            : const SizedBox.shrink();
  }
}
