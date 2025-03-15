part of track_list_widget;

const LIST_GAP = 8.0;

class TrackList extends StatefulWidget {
  const TrackList({
    super.key,
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<TrackSummary>, TrackSummary>(
      listGap: LIST_GAP,
      selector: (state) => state.allTracks,
      itemBuilder: (context, track) => TrackListTile(track: track),
    );
  }
}
