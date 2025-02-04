part of music_page;

class AlbumsGrid extends StatefulWidget {
  const AlbumsGrid({
    super.key,
  });

  @override
  State<AlbumsGrid> createState() => _AlbumsGridState();
}

class _AlbumsGridState extends State<AlbumsGrid> {
  @override
  Widget build(BuildContext context) {
    final alphabet = "#abcdefghijklmnoprstuvwxyz."
        .split('')
        .map(
          (e) => SquareTile(
            size: TileUtility.regularTileWidth,
            alignment: Alignment.bottomRight,
            textStyle: Styles.tileFont,
            text: e,
          ),
        )
        .toList();
    return Expanded(
      /// NOTE: A box in which a single widget can be scrolled
      ///       https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          direction: Axis.horizontal,
          children: alphabet,
        ),
      ),
    );
  }
}
