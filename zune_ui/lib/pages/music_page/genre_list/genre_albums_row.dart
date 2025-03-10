part of genre_list_widget;

const ROW_SIZE = 16.0;
const ROW_GAP = 4.0;

class GenreAlbumsRow extends StatelessWidget {
  final UnmodifiableListView<AlbumSummary> albums;

  const GenreAlbumsRow({
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
