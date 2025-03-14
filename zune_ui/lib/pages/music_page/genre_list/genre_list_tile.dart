part of genre_list_widget;

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

class GenreListTile extends StatelessWidget {
  final GenreSummary genre;

  const GenreListTile({
    super.key,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemWrapper<GenreSummary>(
      data: genre,
      widgetConfigs: [
        // Play Button
        (
          builder: (context, genre) => const ListTilePlayButton(),
          parallaxConfig: parallaxConfig[0]!
        ),
        // Genre Tile
        (
          builder: (context, genre) => Text(
                genre.genre_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.listTileFont,
              ),
          parallaxConfig: parallaxConfig[1]!
        ),
        // Genre Album Row
        (
          builder: (context, genre) =>
              LazyListTileAlbumRow(album_ids: genre.album_ids),
          parallaxConfig: parallaxConfig[2]!
        )
      ],
    );
  }
}
