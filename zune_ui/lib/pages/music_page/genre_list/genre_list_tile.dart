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

  Widget _renderPlayButton() {
    return const Align(
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
          _renderPlayButton(),
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
      /// Play Button
      0: (
        x: 0,
        y: 0,

        /// NOTE: Fine tuned based on "vibes" as  close as I see on Zune display.
        ///       Velocity is largest here to show the "shift" effect when scrolling.
        ///       Signed direct is positive so that when scrolling down the play button
        ///       moves down more apparently.
        velocity: 1 * 8,
        signedDirection: 1,
      ),

      /// Genre Title
      1: (
        x: 36.0 + 8.0,
        y: 12,

        /// NOTE: Lowering velocity here to accentuate play button & album row
        ///       parallax effect.
        ///       Signed direction is negative so that when scrolling down the title
        ///       moves up making more space between title nad the album row.
        velocity: 2 * 2,
        signedDirection: -1,
      ),

      /// Albums Row
      2: (
        x: 36.0 + 8.0,
        y: 32,
        velocity: 3 * 4,
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
