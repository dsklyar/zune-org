part of album_list_widget;

const ROW_SIZE = 80.0;
const ROW_GAP = 4.0;

class AlbumTracksList extends StatelessWidget {
  final UnmodifiableListView<TrackSummary> tracks;
  const AlbumTracksList({
    super.key,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ROW_SIZE,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: tracks.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: ROW_GAP,
          ),
          itemBuilder: (context, index) => Text(
            /// NOTE: Zune has tracks in default case.
            tracks[index].track_name,
            overflow: TextOverflow.ellipsis,
            style: Styles.albumTrackFont,
          ),
        ),
      ),
    );
  }
}

class LazyAlbumTracksList extends StatelessWidget {
  final List<int> track_ids;
  const LazyAlbumTracksList({
    super.key,
    required this.track_ids,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<GlobalModalState>();
    return FutureBuilder<UnmodifiableListView<TrackSummary>>(
      future: globalState.getTracksFromIds(track_ids),
      builder: (context, snapshot) {
        final connectionIsDone =
            snapshot.connectionState == ConnectionState.done;
        final data = snapshot.data;
        final dataIsPresent = data != null && data.isNotEmpty;
        final readyToRender = connectionIsDone && dataIsPresent;
        return readyToRender
            ? AlbumTracksList(tracks: data)
            : const SizedBox.shrink();
      },
    );
  }
}
