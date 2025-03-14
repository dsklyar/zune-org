part of music_common_widgets;

const ROW_SIZE = 16.0;
const ROW_GAP = 4.0;

class ListTileAlbumRow extends StatelessWidget {
  final UnmodifiableListView<AlbumSummary> albums;

  const ListTileAlbumRow({
    super.key,
    required this.albums,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ROW_SIZE,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: albums.length,
          separatorBuilder: (context, index) => const SizedBox(
            width: ROW_GAP,
          ),
          itemBuilder: (context, index) => SquareTile(
            size: ROW_SIZE,
            background: albums[index].album_cover,
          ),
        ),
      ),
    );
  }
}

class LazyListTileAlbumRow extends StatelessWidget {
  final List<int> album_ids;
  const LazyListTileAlbumRow({
    super.key,
    required this.album_ids,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<GlobalModalState>();

    return FutureBuilder<UnmodifiableListView<AlbumSummary>>(
      future: globalState.getAlbumsFromIds(album_ids),
      builder: (
        context,
        AsyncSnapshot<UnmodifiableListView<AlbumSummary>> snapshot,
      ) {
        final connectionIsDone =
            snapshot.connectionState == ConnectionState.done;
        final data = snapshot.data;
        final dataIsPresent = data != null && data.isNotEmpty;
        final readyToRender = connectionIsDone && dataIsPresent;

        return readyToRender
            ? ListTileAlbumRow(
                albums: data,
              )
            : const SizedBox.shrink();
      },
    );
  }
}
