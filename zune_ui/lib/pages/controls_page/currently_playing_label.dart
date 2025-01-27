part of controls_page;

class CurrentlyPlayingLabel extends StatelessWidget {
  const CurrentlyPlayingLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Consumer<GlobalModalState>(
        builder: (context, state, child) => state.currentlyPlaying != null
            ? Column(
                // Align currently playing to left of the display
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideInAnimationWrapper(
                    offset: const Offset(1, 0.0),
                    child: Text(
                      state.currentlyPlaying!.album.artist_name.toUpperCase(),
                      style: Styles.albumArtist,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                  SlideInAnimationWrapper(
                    offset: const Offset(1, 0.0),
                    child: Text(
                      state.currentlyPlaying!.song.name,
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
