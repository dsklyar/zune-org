part of artist_list_widget;

const ARTIST_LIST_GAP = 26.0;
const ARTIST_LIST_TILE_SIZE = 44.0;
const ARTIST_SEARCH_INDEX_TILE_SIZE = TileUtility.smallTileWidth;

const Map<int, ParallaxConfiguration> ARTIST_PARALLAX_CONFIG = {
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
