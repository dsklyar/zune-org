part of track_list_widget;

const LIST_GAP = 20.0;

class TrackList extends StatefulWidget {
  const TrackList({
    super.key,
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  List<TrackListTileGroup> _generateTrackGroups(List<TrackSummary> tracks) =>
      parent.generateItemGroups<TrackSummary, TrackListTileGroup>(
        tracks,
        (groupKey, item) => (groupKey: groupKey, track: item),
        (e) => parent.generateItemGroupKey(e.track_name),
      );

  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<TrackSummary>, TrackSummary,
        TrackListTileGroup>(
      listGap: LIST_GAP,
      selector: (state) => state.allTracks,
      itemBuilder: (context, trackGroup) =>
          TrackListTile(trackGroup: trackGroup),
      itemsReducer: _generateTrackGroups,
    );
  }
}
