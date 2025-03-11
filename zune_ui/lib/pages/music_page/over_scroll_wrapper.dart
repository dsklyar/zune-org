part of music_page;

const OVERSCROLL_THRESHOLD = 84;

class OverScrollWrapper extends StatefulWidget {
  final Widget Function(
    ScrollController scrollController,
    OverScrollPhysics scrollPhysics,
  ) builder;

  const OverScrollWrapper({
    super.key,
    required this.builder,
  });

  @override
  State<OverScrollWrapper> createState() => _OverScrollWrapperState();
}

class _OverScrollWrapperState extends State<OverScrollWrapper> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleOverscroll() {
    final height = MediaQuery.of(context).size.height;

    /// NOTE: Condition to check if over scroll event occurred
    ///       whe user pulling up at the top of the list
    ///        __________
    ///       |    ⬆︎    |
    ///       |    ⬆︎    |
    if (_scrollController.offset < -OVERSCROLL_THRESHOLD) {
      // Instead of .animateTo simply jump to 2 times the height of the container,
      // so that the END list will slide from above.
      _scrollController.jumpTo(height * 2);

      /// NOTE: Condition to check if over scroll event occurred
      ///       whe user pulling down at the bottom of the list
      ///
      ///       |    ⬇︎    |
      ///       |    ⬇︎    |
      ///        ----------
    } else if (_scrollController.offset >
        _scrollController.position.maxScrollExtent + OVERSCROLL_THRESHOLD) {
      // Instead of .animateTo simply jump to negative of the height of the container,
      // so that the START list will slide from below.
      _scrollController.jumpTo(-height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          _handleOverscroll();
        }
        return false;
      },
      child: widget.builder(_scrollController, const OverScrollPhysics()),
    );
  }
}

/// NOTE: Class responsible for deriving over scroll physics event
///       which is derived inside applyBoundaryConditions to return
///       if the scroll had an over scroll.
class OverScrollPhysics extends ScrollPhysics {
  const OverScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  OverScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OverScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    /// NOTE:
    ///       Value - scroll which physics simulation is suggesting
    ///       Position.pixels - the current scroll offset of the scrollable container
    ///       Position.min/maxScrollExtent - the minimum/maximum scroll extent
    ///
    ///       Basically, if the physics suggested value is less than current offset
    ///       and current offset is less or equal to the MINIMUM - OFFSET (offset added for spring effect)
    ///       then return a value which represent the over scroll event.
    if (value < position.pixels &&
        position.pixels <= (position.minScrollExtent - OVERSCROLL_THRESHOLD)) {
      return value - position.pixels;
    }
    // The same logic as above but for the bottom over scroll effect.
    if (value > position.pixels &&
        position.pixels >= (position.maxScrollExtent + OVERSCROLL_THRESHOLD)) {
      return value - position.pixels;
    }
    return 0.0;
  }
}
