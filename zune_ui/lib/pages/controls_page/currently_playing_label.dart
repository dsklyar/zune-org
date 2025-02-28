part of controls_page;

class CurrentlyPlayingLabel extends StatelessWidget {
  const CurrentlyPlayingLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Selector<GlobalModalState, ({TrackSummary? track, int delta})>(
        selector: (context, state) => (
          track: state.currentlyPlaying?.song,
          delta: state.trackChangeDelta
        ),
        builder: (context, state, child) => state.track != null
            ? Column(
                // Align currently playing to left of the display
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrackLabelAnimation(
                    forward: state.delta >= 0,
                    child: Text(
                      state.track!.artist_name.toUpperCase(),
                      style: Styles.albumArtist,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                  TrackLabelAnimation(
                    forward: state.delta >= 0,
                    child: Text(
                      state.track!.track_name,
                      style: Styles.songTitle,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
