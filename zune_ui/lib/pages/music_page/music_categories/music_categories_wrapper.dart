part of music_categories_widget;

class MusicCategoriesWrapper extends StatefulWidget {
  const MusicCategoriesWrapper({
    super.key,
  });

  @override
  State<MusicCategoriesWrapper> createState() => _MusicCategoriesWrapperState();
}

class _MusicCategoriesWrapperState extends State<MusicCategoriesWrapper>
    with SingleTickerProviderStateMixin {
  bool _isDisposed = false;
  late final AnimationController _controller;

  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _rotationAnimation = Tween<double>(
      begin: -90,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.center,
    ).animate(_controller);

    _controller.forward();

    /// NOTE: Don't shoot me 🔫
    ///       This is most likely not the correct way to synchronize animations across
    ///       multiple widgets, BUT the goal is to "register" all logic needed for
    ///       unmount animations across several widgets e.g. MusicCategories & ViewSelector
    ///       which will be executed upon user's exit from "music" menu item.
    _registerUnmountAnimationSequence();
  }

  @override
  void dispose() {
    /// NOTE: Setting _isDisposed to true before controller is disposed
    ///       so that resource is still valid before running registered
    ///       animation sequence below.
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _registerUnmountAnimationSequence() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final musicPlayerAnimationContext =
            MusicPlayerAnimationProvider.of(context);

        musicPlayerAnimationContext?.register(
          EventType.unmountEvent,
          () async {
            /// NOTE: Check if the widget is not yet disposed before
            ///       attempting to reverse the animation controller.
            if (!_isDisposed && mounted) {
              await _controller.reverse();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform(
          alignment: _alignmentAnimation.value,
          transform: Matrix4.identity()
            ..scale(_scaleAnimation.value)
            ..rotateY(_rotationAnimation.value * (pi / 180)),
          child: const MusicCategories(),
        ),
      ),
    );
  }
}
