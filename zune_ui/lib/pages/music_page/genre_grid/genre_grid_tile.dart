part of genre_grid_widget;

class GenreGridTile extends StatelessWidget {
  final GenreSummary genre;
  final GlobalKey _globalKey = GlobalKey();

  GenreGridTile({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<GlobalModalState>();

    return Container(
      height: 72,
      child: Stack(
        children: [
          const CircleWidget(
            size: 36,
            borderWidth: 2,
            child: Icon(
              Icons.play_arrow,
              size: 28,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 8,
            left: 36 + 8,
            child: Text(
              genre.genre_name.toUpperCase(),
              style: Styles.genreTileFont,
            ),
          ),
          Positioned(
            left: 36 + 8,
            top: 28,
            child: FutureBuilder<UnmodifiableListView<AlbumSummary>>(
              future: globalState.getAlbumsFromIds(genre.album_ids),
              builder: (
                context,
                AsyncSnapshot<UnmodifiableListView<AlbumSummary>> snapshot,
              ) {
                final doneLoading =
                    snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty;
                final albums = snapshot.data;

                return doneLoading
                    ? Row(
                        spacing: 4,
                        children: [
                          ...albums!.map(
                            (album) => SquareTile(
                              size: 16,
                              background: album.album_cover,
                            ),
                          )
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
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
