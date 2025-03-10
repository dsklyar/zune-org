part of view_selector_widget;

enum AnimationType {
  //      []
  mount(Offset.zero),
  // [] -> *
  slideFromLeft(Offset(-1.0, 0.0)),
  //       * <- []
  slideFromRight(Offset(1.0, 0.0));

  final Offset offset;
  const AnimationType(this.offset);

  static AnimationType deriveCurrentAnimationType(int delta) {
    return delta > 0
        ? AnimationType.slideFromRight
        : delta < 0
            ? AnimationType.slideFromLeft
            : AnimationType.mount;
  }
}

const THRESHOLD_FOR_DRAG = 0.2;

class ViewSelector extends StatefulWidget {
  const ViewSelector({
    super.key,
  });

  @override
  State<ViewSelector> createState() => _ViewSelectorState();
}

class _ViewSelectorState extends State<ViewSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _xOffsetFadeAnimation;

  double _xOffset = 0;
  late MusicCategoryType _activeCategory;
  AnimationType _currentAnimationType = AnimationType.mount;

  @override
  void initState() {
    super.initState();

    _activeCategory = context.read<GlobalModalState>().lastSelectedCategory;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _xOffsetFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextActiveCategory =
        context.watch<GlobalModalState>().lastSelectedCategory;

    /// NOTE: Need to derive the delta change between current and next selected music category
    ///       in order to simulate correct slideIn/Out animation based on which category was selected.
    final categoryDelta = MusicCategoryType.getMusicDeltaChange(
      _activeCategory,
      nextActiveCategory,
    );

    // If delta is 0, no category change has been made.
    if (categoryDelta == 0) return;

    _animateTransition(
      categoryDelta,
      callback: () {
        /// NOTE: Basically, _animateTransition -> categoryDelta is animating current active music
        ///       category to the direction where user slide to, AND after the animation is complete
        ///       updating the animation/active category to for the next slideIn/Out animation.
        ///
        ///       Afterwards, resetting _controller and starting animation again in order to animate
        ///       next active category slideIn/Out animation.
        setState(() {
          _currentAnimationType =
              AnimationType.deriveCurrentAnimationType(categoryDelta);
          _activeCategory = nextActiveCategory;
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// NOTE: Derives the offset for the  drag animation.
  ///       Zune has a threshold of sorts to stagger animation,
  ///       thus until absolute _xOffset reaches a screenSize.width * THRESHOLD_FOR_DRAG
  ///       the drag animation will not render.
  Offset getThresholdOffset() {
    final screenSize = MediaQuery.of(context).size;

    if (_xOffset.abs() < screenSize.width * THRESHOLD_FOR_DRAG) {
      return Offset.zero;
    } else {
      return Offset(_xOffset, 0);
    }
  }

  void _animateTransition(int delta, {void Function()? callback}) {
    final screenSize = MediaQuery.of(context).size;

    /// NOTE: Derive end offset to where the category view will animate to
    ///       when user slides the category to go to prev/next one.
    final endOffset = delta > 0 ? -screenSize.width : screenSize.width;

    final Animation<double> viewOffsetX =
        Tween<double>(begin: _xOffset, end: endOffset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    void listener() {
      setState(() {
        _xOffset = viewOffsetX.value;
      });
    }

    _controller.addListener(listener);

    _controller.forward().then(
      (value) {
        _controller.removeListener(listener);
        _controller.reset();

        setState(() {
          _xOffset = 0;
        });

        if (callback != null) {
          callback();
        }
      },
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) => setState(() {
        _xOffset += details.delta.dx;
      });

  void _onHorizontalDragEnd(DragEndDetails details) {
    /// NOTE: Performing this check in order to omit any GestureDetectors
    ///       captures where _xOffset was not changed by the Horizontal drag event.
    if (_xOffset.round() == 0) return;

    /// NOTE: Performing this check to prevent category change when user
    ///       drags the view back under threshold of the slide window.
    ///       This way if user is fidgeting and returns view back, no category change
    ///       is made.
    final screenSize = MediaQuery.of(context).size;
    if (_xOffset.abs() <= screenSize.width * THRESHOLD_FOR_DRAG) return;

    /// NOTE: Deriving delta change for the next selected music category via _xOffset.
    ///       [->]: If offset is positive, user is moving to the RIGHT so the next category
    ///             is going to be the previous one, thus need to times by -1 will result in NEGATIVE delta
    ///       [<-]: If offset is negative, user is moving to the LEFT so the next category
    ///             is going to be the next one, thus need to times by -1 will result in POSITIVE delta
    final delta = -1 * _xOffset.round();
    context.read<GlobalModalState>().navigateToCategory(delta);
  }

  Widget renderCategoryType(MusicCategoryType type) {
    switch (type) {
      case MusicCategoryType.albums:
        return const AlbumsGrid();
      case MusicCategoryType.genres:
        return const GenreList();
      case MusicCategoryType.artists:
        return const GenreList();
      default:
        return const EmptyCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewSlideTransition(
      activeCategory: _activeCategory,
      child: ViewMountTransition(
        enabled: _currentAnimationType == AnimationType.mount,
        child: FadeTransition(
          opacity: _xOffsetFadeAnimation,
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Transform.translate(
              offset: getThresholdOffset(),
              child: renderCategoryType(_activeCategory),
            ),
          ),
        ),
      ),
    );
  }
}
