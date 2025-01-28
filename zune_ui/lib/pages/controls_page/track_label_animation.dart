part of controls_page;

class TrackLabelAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final bool forward;

  const TrackLabelAnimation({
    Key? key,
    required this.child,
    required this.forward,
    this.duration = const Duration(milliseconds: 250),
    this.offset = const Offset(1.0, 0.0),
  }) : super(key: key);

  @override
  State<TrackLabelAnimation> createState() => _TrackLabelAnimationState();
}

class _TrackLabelAnimationState extends State<TrackLabelAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<Offset> _forwardSlideInAnimation;
  late Animation<Offset> _forwardSlideOutAnimation;
  late Animation<Offset> _backwardSlideInAnimation;
  late Animation<Offset> _backwardSlideOutAnimation;
  late Animation<double> _fadeAnimation;

  /// Flag to track if the widget is mounted
  bool _isMounted = true;

  Widget? _mountedChild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _mountedChild = widget.child;

    _forwardSlideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
        -widget.offset.dx * 2,
        0,
      ),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _forwardSlideInAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _backwardSlideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _backwardSlideInAnimation = Tween<Offset>(
      begin: Offset(
        -widget.offset.dx * 2,
        0,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _animation =
        widget.forward ? _forwardSlideInAnimation : _backwardSlideInAnimation;

    // Prevent controller trigger when component is unmounted
    if (_isMounted) {
      // Start the slide-in animation
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TrackLabelAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// On widget update, need to delay child update so that slide out/in
    /// animation can play when user/rust updates the next/prev track change.
    /// Thus, if the latest trackDeltaChange is forward, set the correct
    /// slide out animation, reset the controller and play the slide out
    /// animation with old text. This will allow old album/track name to slide out
    /// based on the forward direction and queue the next animation. Afterwards,
    /// mount the new album/track name child and again update animation to
    /// correct slide in animation.
    if (widget.child != oldWidget.child) {
      setState(() {
        _animation = widget.forward
            ? _forwardSlideOutAnimation
            : _backwardSlideOutAnimation;
        _fadeAnimation =
            Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
        _controller.reset();
        _controller.forward().then((_) {
          _mountedChild = widget.child;

          setState(() {
            _animation = widget.forward
                ? _forwardSlideInAnimation
                : _backwardSlideInAnimation;
            _fadeAnimation =
                Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
            _controller.reset();
            _controller.forward();
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isMounted = false;
    return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _animation,
          child: _mountedChild,
        ));
  }
}
