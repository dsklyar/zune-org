part of over_scroll_wrapper;

/// TODO:
///       Changing 84 to 168 threshold to prevent overscroll trigger
///       during the search index animation to latter letter causing
///       wrong positions.
const OVERSCROLL_THRESHOLD = 168;

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
    Future<void> animateScrollTo(
        double initialJump, double finalPosition) async {
      try {
        _scrollController.jumpTo(initialJump);

        /// TODO: This is a hack?
        ///       Basically, in album grid, the widget get stuck outside of scroll
        ///       when using mac touchpad and flicking fast up/down. It might be because
        ///       of a complex grid builder in the album view, but not sure.
        ///
        ///       Adding this promise to execute animation to final scroll position after
        ///       initial .jumpTo call.
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            finalPosition,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        console.error(e);
      }
    }

    /// NOTE: Condition to check if over scroll event occurred
    ///       whe user pulling up at the top of the list
    ///        __________
    ///       |    ⬆︎    |
    ///       |    ⬆︎    |
    if (_scrollController.offset < -OVERSCROLL_THRESHOLD) {
      // Instead of .animateTo simply jump to 2 times the maxScrollExtent of the container,
      // so that the END list will slide from above.
      animateScrollTo(
        _scrollController.position.maxScrollExtent * 2,
        _scrollController.position.maxScrollExtent,
      );

      /// NOTE: Condition to check if over scroll event occurred
      ///       whe user pulling down at the bottom of the list
      ///
      ///       |    ⬇︎    |
      ///       |    ⬇︎    |
      ///        ----------
    } else if (_scrollController.offset >
        _scrollController.position.maxScrollExtent + OVERSCROLL_THRESHOLD) {
      // Instead of .animateTo simply jump to negative of the maxScrollExtent of the container,
      // so that the START list will slide from below.
      animateScrollTo(
        -_scrollController.position.maxScrollExtent,
        0.0,
      );
    }
  }

  bool _onNotification(ScrollNotification notification) {
    // Capture if event is Overscroll driven by applyBoundaryConditions method below
    if (notification is OverscrollNotification) {
      _handleOverscroll();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
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
