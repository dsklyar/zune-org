part of genre_list_widget;

class GenreListTile extends StatelessWidget {
  final GenreSummary genre;

  const GenreListTile({
    super.key,
    required this.genre,
  });

  Widget _renderAlbumList(BuildContext context) {
    final globalState = context.read<GlobalModalState>();

    return FutureBuilder<UnmodifiableListView<AlbumSummary>>(
      future: globalState.getAlbumsFromIds(genre.album_ids),
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
            ? GenreAlbumsRow(
                albums: data,
              )
            : const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      child: Flow(
        /// NOTE: Need to remove clipping here because the play button
        ///       during translation inside the Flow
        clipBehavior: Clip.none,
        delegate: ParallaxFlowDelegate(
          itemContext: context,
          scrollable: Scrollable.of(context),
        ),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CircleWidget(
              size: 36,
              borderWidth: 2,
              child: Icon(
                Icons.play_arrow,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            genre.genre_name.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: Styles.genreTileFont,
          ),
          _renderAlbumList(context),
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

  ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
  }) : super(repaint: scrollable.position);

  // @override
  // BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
  //   // Return tight width constraints for your background image child.
  //   return BoxConstraints.tightFor(
  //     width: constraints.maxWidth,
  //   );
  // }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = itemContext.findRenderObject() as RenderBox;

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Since these items are lazy loaded by parent's GridView
    // here is the logic to get current item global scrolled offset:
    final listItemOffset = listItemBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    // Basically, take the items offset and divide by scrollable viewport dimension e.g. 360.
    // This should give a ratio which is clamped [-1, 1] of how far the item was scrolled.
    // Trying to encode scale/translate here is counter intuitive so its best to do translate in the widget.
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(-1.0, 1.0);

    final Map<
        int,
        ({
          double x,
          double y,
          double velocity,
          int signedDirection,
        })> map = {
      0: (
        x: 0,
        y: 0,
        velocity: 8,
        signedDirection: -1,
      ),
      1: (
        x: 36.0 + 8.0,
        y: 4,
        velocity: 1 * 4,
        signedDirection: 1,
      ),
      2: (
        x: 36.0 + 8.0,
        y: 28,
        velocity: 2 * 4,
        signedDirection: -1,
      ),
    };

    for (int i = 0; i < context.childCount; i++) {
      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(
            map[i]!.x,
            map[i]!.y +
                scrollFraction * map[i]!.velocity * map[i]!.signedDirection,
            0.0,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        itemContext != oldDelegate.itemContext;
  }
}
