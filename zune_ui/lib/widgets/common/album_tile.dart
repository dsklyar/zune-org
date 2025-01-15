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
    final double size = isPlayedCurrently ? 160 : 78;
    final Uint8List? pathToAlbumCover = album.album_image;
    final TextStyle albumTextStyle = isPlayedCurrently
        ? TextStyles.currentlyPlayedTitle
        : TextStyles.albumTitle;
    final String? albumName =
        ((album.album_image != null && isPlayedCurrently) ||
                album.album_image == null)
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

class SquareTile extends StatelessWidget {
  final String? text;
  final Uint8List? background;
  final AlignmentGeometry? alignment;
  final TextStyle? textStyle;
  final double size;

  const SquareTile({
    super.key,
    required this.size,
    this.text,
    this.background,
    this.alignment = Alignment.bottomLeft,
    this.textStyle = TextStyles.albumTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: background == null
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                width: 1,
                color: Colors.white,
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
              child: Text(text!, style: textStyle),
            )
        ],
      ),
    );
  }
}
