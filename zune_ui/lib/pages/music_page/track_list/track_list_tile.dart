part of track_list_widget;

typedef TrackListTileGroup = ({String? groupKey, TrackSummary? track});

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
  final TrackListTileGroup trackGroup;

  const TrackListTile({
    super.key,
    required this.trackGroup,
  });

  Widget generateGroupKeyTile(BuildContext context, String groupKey) {
    /// NOTE: This provider exposes all of the overlays in the app.
    final overlaysProvider = OverlaysProvider.of(context);
    return SizedBox(
      child: Align(
        alignment: Alignment.centerLeft,
        child: SearchIndexTile(
          index: trackGroup.groupKey!,
          onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
        ),
      ),
    );
  }

  Widget generateTrackTile(BuildContext context, TrackSummary track) {
    return ListItemWrapper<TrackSummary>(
      data: track,
      height: 32.0,
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

  @override
  Widget build(BuildContext context) {
    return trackGroup.groupKey != null
        ? generateGroupKeyTile(context, trackGroup.groupKey!)
        : trackGroup.track != null
            ? generateTrackTile(context, trackGroup.track!)
            : const SizedBox.shrink();
  }
}
