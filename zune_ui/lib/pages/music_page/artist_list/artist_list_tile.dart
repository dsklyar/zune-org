part of artist_list_widget;

typedef ArtistListTileGroup = ({String? groupKey, ArtistSummary? artist});

class ArtistListTile extends StatelessWidget {
  final ArtistListTileGroup artistGroup;

  const ArtistListTile({
    super.key,
    required this.artistGroup,
  });

  Widget generateGroupKeyTile(BuildContext context, String groupKey) {
    /// NOTE: This provider exposes all of the overlays in the app.
    final overlaysProvider = OverlaysProvider.of(context);
    return SizedBox(
      child: Align(
        alignment: Alignment.centerLeft,
        child: SearchIndexTile(
          index: artistGroup.groupKey!,
          onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
        ),
      ),
    );
  }

  Widget generateArtistTile(BuildContext context, ArtistSummary artist) {
    return ListItemWrapper<ArtistSummary>(
      data: artist,
      height: ARTIST_LIST_TILE_SIZE,
      widgetConfigs: [
        // Play Button
        (
          builder: (context, artist) => const ListTilePlayButton(),
          parallaxConfig: ARTIST_PARALLAX_CONFIG[0]!
        ),
        // Artist Tile
        (
          builder: (context, artist) => Text(
                artist.artist_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.listTileFont,
              ),
          parallaxConfig: ARTIST_PARALLAX_CONFIG[1]!
        ),
        // Artist Album Row
        (
          builder: (context, artist) =>
              LazyListTileAlbumRow(album_ids: artist.album_ids),
          parallaxConfig: ARTIST_PARALLAX_CONFIG[2]!
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return artistGroup.groupKey != null
        ? generateGroupKeyTile(context, artistGroup.groupKey!)
        : artistGroup.artist != null
            ? generateArtistTile(context, artistGroup.artist!)
            : const SizedBox.shrink();
  }
}
