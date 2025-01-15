part of support_menu;

class CurrentItem extends StatelessWidget {
  final AlbumModel? album;
  final bool isPlaying;
  final void Function(AlbumModel) onClickHandler;

  const CurrentItem({
    super.key,
    this.album,
    this.isPlaying = false,
    required this.onClickHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 64),
        if (album != null)
          Text(isPlaying ? "Playing" : "Paused", style: Styles.tileText),
        if (album != null)
          AlbumTile(
            album: album!,
            isPlayedCurrently: true,
            onAlbumClick: onClickHandler,
          ),
        if (album != null) const SizedBox(height: 32),
      ],
    );
  }
}
