part of track_list_widget;

const TRACK_LIST_GAP = 20.0;
const TRACK_LIST_TILE_SIZE = 33.0;
const TRACK_SEARCH_INDEX_TILE_SIZE = TileUtility.smallTileWidth;

final Map<int, ParallaxConfiguration> TRACK_PARALLAX_CONFIG = {
  // Track Title
  0: (
    x: 0,
    y: 0,
    velocity: 0,
    signedDirection: 0,
  ),
  // Track Artist & Album Name
  1: (
    x: 0,
    y: 20,
    velocity: 0,
    signedDirection: 0,
  ),
};
