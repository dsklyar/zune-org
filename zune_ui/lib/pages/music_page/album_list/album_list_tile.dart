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
        child: SearchIndexTile(
          index: albumGroup.groupKey!,
          onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
        ),
      ),
    );
  }

  Widget generateAlbumTile(BuildContext context, AlbumSummary album) {
    final albumCover = album.album_cover;
    final albumName = album.album_name;

    return GestureDetector(
      // key: _albumTileKey,
      // onTap: onAlbumTapHandler,
      child: Stack(
        children: [
          SquareTile(
            size: TileUtility.mediumTileWidth,
            alignment: Alignment.bottomRight,
            textStyle: Styles.albumTileFont,
            background: albumCover,
            text: albumCover != null ? null : albumName.toUpperCase(),
          ),
        ],
      ),
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
