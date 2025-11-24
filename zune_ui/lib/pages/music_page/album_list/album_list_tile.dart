part of album_list_widget;

typedef AlbumListTileGroup = ({String? groupKey, AlbumSummary? album});

/// NOTE: Helper cache to store the wrapping state of the album title.
/// LRU Cache with a max size of 1000 entries.
final LRUCache<String, bool> _titleWrapCache =
    LRUCache<String, bool>(maxSize: 1000);

class AlbumListTile extends StatelessWidget {
  final AlbumListTileGroup albumGroup;

  const AlbumListTile({
    super.key,
    required this.albumGroup,
  });

  static bool isTextWrapping(
    String text,
    TextStyle style,
    int maxLines,
    double maxWidth,
  ) {
    // Create cache key: title
    final cacheKey = text;

    // Check cache first
    if (_titleWrapCache.containsKey(cacheKey)) {
      return _titleWrapCache[cacheKey]!;
    }
    // If not in cache, measure text and store result
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    textPainter.layout(maxWidth: maxWidth);

    final singleLineHeight = style.fontSize! * style.height!;
    final didWrap = textPainter.height > singleLineHeight;

    textPainter.dispose();

    _titleWrapCache[cacheKey] = didWrap;
    return _titleWrapCache[cacheKey]!;
  }

  /// NOTE: Because the album title can sometimes wrap, need to regenerate the y offset
  ///       for the album artist to ensure it is positioned correctly following
  ///       the zune experience.
  ///
  ///       Basically, the album title pushes down on artist name which is not wrapping
  ///       and the artist name is pushed down accordingly.
  static ParallaxConfiguration adjustYOffsetForWrapping(
      bool isWrapping, ParallaxConfiguration config) {
    return (
      x: config.x,
      y: isWrapping
          ? config.y + Styles.albumTitleFont.fontSize!.toDouble()
          : config.y,
      velocity: config.velocity,
      signedDirection: config.signedDirection,
      constraints: config.constraints,
    );
  }

  Widget generateGroupKeyTile(BuildContext context, String groupKey) {
    /// NOTE: This provider exposes all of the overlays in the app.
    final overlaysProvider = OverlaysProvider.of(context);
    return SizedBox(
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
          child: SquareTile(
            size: ALBUM_LIST_TILE_SIZE,
            alignment: Alignment.bottomRight,
            noBorder: true,
            child: SquareTile(
              size: TileUtility.smallTileWidth,
              alignment: Alignment.bottomRight,
              textStyle: Styles.searchTileFont,
              text: albumGroup.groupKey!,
            ),
          ),
        ),
      ),
    );
  }

  Widget generateAlbumTile(BuildContext context, AlbumSummary album) {
    final isAlbumNameWrapping = isTextWrapping(
        album.album_name, Styles.albumTitleFont, 2, REMAINING_WIDTH);
    return ListItemWrapper<AlbumSummary>(
      data: album,
      height: ALBUM_LIST_TILE_SIZE,
      widgetConfigs: [
        // Album Cover
        (
          builder: (context, album) => Consumer<GlobalModalState>(
                builder: (context, state, child) => GestureDetector(
                  onTap: () {
                    state.updateCurrentlyPlaying(album);
                    context.push(ApplicationRoute.player.route);
                  },
                  child: Container(
                    // NOTE: This is to ensure the album cover is centered vertically.
                    alignment: Alignment.centerLeft,
                    child: SquareTile(
                      size: ALBUM_LIST_TILE_SIZE,
                      alignment: Alignment.bottomRight,
                      textStyle: Styles.searchTileFont
                          .copyWith(fontWeight: FontWeight.w100),
                      background: album.album_cover,
                      text: album.album_cover != null
                          ? null
                          : album.album_name.toUpperCase(),
                    ),
                  ),
                ),
              ),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[0]!,
        ),
        // Play Button
        (
          builder: (context, _) => const ListTilePlayButton(),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[1]!
        ),
        // Albums Title
        (
          builder: (context, album) => Text(
                album.album_name.toUpperCase(),
                style: Styles.albumTitleFont,
                // NOTE: This is to ensure the album title is wrapped if it is wrapping.
                maxLines: isAlbumNameWrapping ? 2 : 1,
                overflow: TextOverflow.visible,
              ),
          parallaxConfig: ALBUM_LIST_PARALLAX_CONFIG[2]!
        ),
        // Albums Artist
        (
          builder: (context, album) => Text(
                album.artist_name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Styles.albumArtistFont,
              ),
          parallaxConfig: adjustYOffsetForWrapping(
            isAlbumNameWrapping,
            ALBUM_LIST_PARALLAX_CONFIG[3]!,
          )
        ),
        // Albums Songs
        (
          builder: (context, album) =>
              LazyAlbumTracksList(track_ids: album.track_ids),
          parallaxConfig: adjustYOffsetForWrapping(
            isAlbumNameWrapping,
            ALBUM_LIST_PARALLAX_CONFIG[4]!,
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return albumGroup.groupKey != null
        ? generateGroupKeyTile(context, albumGroup.groupKey!)
        : albumGroup.album != null
            ? generateAlbumTile(context, albumGroup.album!)
            : const SizedBox.shrink();
  }
}
