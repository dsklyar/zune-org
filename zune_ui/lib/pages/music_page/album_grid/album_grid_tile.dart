part of album_grid_widget;

typedef AlbumGridTileGroup = ({String? groupKey, AlbumSummary? album});

// NOTE: Variables used to scale/translate album name in the parallax effect.
const SCALE_VALUE = 3;
const INVERSE_SCALE_VALUE = 1 / SCALE_VALUE;

class AlbumsGridTile extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();

  final AlbumGridTileGroup albumGroup;

  AlbumsGridTile({
    super.key,
    required this.albumGroup,
  });

  Widget generateGroupKeyTile(BuildContext context, String groupKey) {
    /// NOTE: This provider exposes all of the overlays in the app.
    final overlaysProvider = OverlaysProvider.of(context);
    return GestureDetector(
      /// NOTE: Show Search Index Page on group key tap.
      onTap: () => overlaysProvider!.showOverlay(OverlayType.searchIndex),
      child: SquareTile(
        size: TileUtility.regularTileWidth,
        alignment: Alignment.bottomRight,
        textStyle: Styles.searchTileFont,
        text: albumGroup.groupKey!,
      ),
    );
  }

  Widget generateAlbumTile(BuildContext context, AlbumSummary album) {
    final albumCover = album.album_cover;
    final albumName = album.album_name;

    return Stack(
      children: [
        SquareTile(
          size: TileUtility.regularTileWidth,
          alignment: Alignment.bottomRight,
          textStyle: Styles.albumTileFont,
          background: albumCover,
          text: albumCover != null ? null : albumName.toUpperCase(),
        ),
        Transform(
          transform: Matrix4.identity()
            // Honestly this is best I could come up with.
            ..scale(INVERSE_SCALE_VALUE)
            // Computing with SCALE_VALUE * .95 to closely match spacing as in Zune UI
            ..translate(TileUtility.regularTileWidth * SCALE_VALUE * .95,
                TileUtility.regularTileWidth, 0.0),
          child: OverflowBox(
            alignment: Alignment.center,
            maxHeight: TileUtility.regularTileWidth * SCALE_VALUE,
            child: Flow(
              delegate: ParallaxFlowDelegate(
                scrollable: Scrollable.of(context),
                itemContext: context,
                itemKey: _globalKey,
              ),
              children: [
                Text(key: _globalKey, albumName),
              ],
            ),
          ),
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

/// NOTE: This code is taken & slightly modified from:
///       -> https://docs.flutter.dev/cookbook/effects/parallax-scrolling
///
class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final GlobalKey itemKey;

  ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
    required this.itemKey,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    // Return tight width constraints for your background image child.
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = itemContext.findRenderObject() as RenderBox;

    // Since these items are lazy loaded by parent's GridView
    // here is the logic to get current item global scrolled offset:
    final listItemOffset = listItemBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    // If needed here is the item height
    // final listItemHeight = listItemBox.size.height;

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Basically, take the items offset and divide by scrollable viewport dimension e.g. 360.
    // This should give a ratio which is clamped [-1, 1] of how far the item was scrolled.
    // Trying to encode scale/translate here is counter intuitive so its best to do translate in the widget.
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(-1.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    // Encoding Y-Axis alignment [-1, 1], which will be inscribed onto the area
    final verticalAlignment = Alignment(0.0, -scrollFraction);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (itemKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = context.size;
    // Inscribing
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    // Paint the background.
    context.paintChild(
      0,
      transform: Transform.translate(
        offset: Offset(
          // Skipping DX because translate will cover this change
          0.0,
          childRect.top,
        ),
      ).transform,
      // Adding opacity to match the Zune's aesthetics.
      opacity: 0.5,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        itemContext != oldDelegate.itemContext ||
        itemKey != oldDelegate.itemKey;
  }
}
