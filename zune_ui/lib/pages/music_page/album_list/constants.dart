part of album_list_widget;

const ALBUM_LIST_GAP = 10.0;

/// TODO: Because I am viewing this with the MusicCategories on 2 - lines,
///       it should show at most 3 albums including with the group key tile.
const ALBUM_LIST_TILE_SIZE = 128.0;

/// NOTE: Remaining width is the width of the album list tile minus the album cover size and padding.
const REMAINING_WIDTH = 272.0 - ALBUM_LIST_TILE_SIZE - 16.0;

const Map<int, ParallaxConfiguration> ALBUM_LIST_PARALLAX_CONFIG = {
  /// Album Cover
  0: (
    x: 0,
    y: 0, // TODO: Change this to the actual y position of the album cover

    velocity: 2 * 2,
    signedDirection: -1,
    constraints: null,
  ),

  /// Play Button
  1: (
    x: ALBUM_LIST_TILE_SIZE - PLAY_BUTTON_SIZE - 4.0 /* Padding */,
    y: 0,

    /// NOTE: Fine tuned based on "vibes" as  close as I see on Zune display.
    ///       Velocity is largest here to show the "shift" effect when scrolling.
    ///       Signed direct is positive so that when scrolling down the play button
    ///       moves down more apparently.
    velocity: 1 * 8,
    signedDirection: 1,
    constraints: null,
  ),

  /// Albums Title
  2: (
    x: ALBUM_LIST_TILE_SIZE + 16.0 /* Padding */,
    y: 0,
    velocity: 1 * 4,
    signedDirection: -1,

    /// NOTE: Adding this constraints override to allow text such as album title
    ///       to overflow the width of the parent container.
    ///       If constraints are not provided, set the width to the remaining width
    ///       of the album list tile.
    constraints: BoxConstraints.tightFor(width: REMAINING_WIDTH),
  ),

  /// Albums Artist
  3: (
    x: ALBUM_LIST_TILE_SIZE + 16.0 /* Padding */,
    y: 16.0 /* Font size for album name */ + 4.0 /* Padding */,
    velocity: 2 * 4,
    signedDirection: -1,
    constraints: null,
  ),

  /// Albums Songs
  4: (
    x: ALBUM_LIST_TILE_SIZE + 16.0 /* Padding */,
    y: 16.0 /* Font size for album name */ + 4.0 /* Padding */ + 18.0,
    velocity: 3 * 6,
    signedDirection: -1,
    constraints: null,
  ),
};
