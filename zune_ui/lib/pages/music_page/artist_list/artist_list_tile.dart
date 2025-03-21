part of artist_list_widget;

typedef ArtistListTileGroup = ({String? groupKey, ArtistSummary? artist});

final Map<int, ParallaxConfiguration> parallaxConfig = {
  /// Play Button
  0: (
    x: 0,
    y: 0,

    /// NOTE: Fine tuned based on "vibes" as  close as I see on Zune display.
    ///       Velocity is largest here to show the "shift" effect when scrolling.
    ///       Signed direct is positive so that when scrolling down the play button
    ///       moves down more apparently.
    velocity: 1 * 8,
    signedDirection: 1,
  ),

  /// Artist Title
  1: (
    x: 36.0 + 8.0,
    y: 12,

    /// NOTE: Lowering velocity here to accentuate play button & album row
    ///       parallax effect.
    ///       Signed direction is negative so that when scrolling down the title
    ///       moves up making more space between title nad the album row.
    velocity: 2 * 2,
    signedDirection: -1,
  ),

  /// Albums Row
  2: (
    x: 36.0 + 8.0,
    y: 32,
    velocity: 3 * 4,
    signedDirection: -1,
  ),
};

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
      widgetConfigs: [
        // Play Button
        (
          builder: (context, artist) => const ListTilePlayButton(),
          parallaxConfig: parallaxConfig[0]!
        ),
        // Artist Tile
        (
          builder: (context, artist) => Text(
                artist.artist_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.listTileFont,
              ),
          parallaxConfig: parallaxConfig[1]!
        ),
        // Artist Album Row
        (
          builder: (context, artist) =>
              LazyListTileAlbumRow(album_ids: artist.album_ids),
          parallaxConfig: parallaxConfig[2]!
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
