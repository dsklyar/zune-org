part of track_list_widget;

final Map<int, ParallaxConfiguration> parallaxConfig = {
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

class TrackListTile extends StatelessWidget {
  final TrackSummary track;

  const TrackListTile({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemWrapper<TrackSummary>(
      data: track,
      widgetConfigs: [
        // Track Title
        (
          builder: (context, track) => Text(
                track.track_name,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Styles.listTileFont.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
          parallaxConfig: parallaxConfig[0]!
        ),
        // Track Artist & Album Name
        (
          builder: (context, track) => Text(
                "${track.artist_name}  ${track.album_name}".toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Styles.listSubtileFont,
              ),
          parallaxConfig: parallaxConfig[1]!
        ),
      ],
    );
  }
}
