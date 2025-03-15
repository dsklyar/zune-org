part of playlist_list_widget;

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

class PlaylistListTile extends StatelessWidget {
  final PlaylistSummary playlist;

  const PlaylistListTile({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemWrapper<PlaylistSummary>(
      data: playlist,
      widgetConfigs: [
        // Play Button
        (
          builder: (context, Playlist) => const ListTilePlayButton(),
          parallaxConfig: parallaxConfig[0]!
        ),
        // Playlist Tile
        (
          builder: (context, Playlist) => Text(
                playlist.playlist_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.listTileFont,
              ),
          parallaxConfig: parallaxConfig[1]!
        ),
        // Playlist Song Count Row
        (
          builder: (context, Playlist) => Text(
                "${playlist.track_ids.length} songs".toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.listSubtileFont,
              ),
          parallaxConfig: parallaxConfig[2]!
        )
      ],
    );
  }
}
