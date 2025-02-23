part of "index.dart";

class TextStyles {
  static const TextStyle currentlyPlayedTitle = TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontSize: 18,
    height: 1,
  );
  static const TextStyle albumTitle = TextStyle(
    fontWeight: FontWeight.w100,
    color: Colors.white,
    fontSize: 12,
    height: 1,
  );
  static const TextStyle searchIndexTile = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 1,
  );
}

class TileUtility {
  static const double largeTileWidth = 160;
  static const double regularTileWidth = 78;
  static const double smallTileWidth = 56;
}

class AlbumTile extends StatelessWidget {
  final AlbumModel album;
  final bool isPlayedCurrently;
  final void Function(AlbumModel album) onAlbumClick;

  const AlbumTile(
      {super.key,
      required this.album,
      this.isPlayedCurrently = false,
      required this.onAlbumClick});

  @override
  Widget build(BuildContext context) {
    final double size = isPlayedCurrently
        ? TileUtility.largeTileWidth
        : TileUtility.regularTileWidth;
    final Uint8List? pathToAlbumCover = album.album_cover;
    final TextStyle albumTextStyle = isPlayedCurrently
        ? TextStyles.currentlyPlayedTitle
        : TextStyles.albumTitle;
    final String? albumName =
        ((album.album_cover != null && isPlayedCurrently) ||
                album.album_cover == null)
            ? album.album_name.toUpperCase()
            : null;

    return GestureDetector(
      onTap: () => onAlbumClick(album),
      child: SquareTile(
        size: size,
        text: albumName,
        alignment: Alignment.bottomLeft,
        textStyle: albumTextStyle,
        background: pathToAlbumCover,
      ),
    );
  }
}

class TrackTile extends StatelessWidget {
  final Uint8List? albumCover;
  final void Function()? onTap;

  const TrackTile({
    super.key,
    required this.albumCover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SquareTile(
        size: TileUtility.largeTileWidth,
        alignment: Alignment.bottomLeft,
        background: albumCover,
        fillBackground: albumCover == null,
      ),
    );
  }
}

class SearchIndexTile extends StatelessWidget {
  final String index;
  final void Function() onTap;

  const SearchIndexTile({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SquareTile(
        size: TileUtility.smallTileWidth,
        alignment: Alignment.bottomRight,
        textStyle: TextStyles.searchIndexTile,
        text: index,
      ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String? text;
  final Uint8List? background;
  final AlignmentGeometry? alignment;
  final TextStyle? textStyle;
  final bool? fillBackground;
  final double size;

  const SquareTile({
    super.key,
    required this.size,
    this.text,
    this.background,
    this.alignment = Alignment.bottomLeft,
    this.textStyle = TextStyles.albumTitle,
    // If true removes border and applies color
    this.fillBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: background == null
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              color: fillBackground == true
                  ? Colors.white.withAlpha(50)
                  : Colors.black,
              border: fillBackground == true
                  ? null
                  : Border.all(
                      width: 1,
                      color: Colors.white.withAlpha(50),
                    ),
            )
          : null,
      child: Stack(
        alignment: alignment!,
        children: [
          if (background != null) Image.memory(background!),
          if (text != null)
            Container(
              padding: const EdgeInsets.all(4.0),

              /// NOTE: Zune only shows maximum of 3 lines from the title
              child: Text(
                text!,
                style: textStyle,
                maxLines: 3,
              ),
            )
        ],
      ),
    );
  }
}
