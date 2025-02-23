part of view_selector_widget;

class ViewMountTransition extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const ViewMountTransition({
    super.key,
    required this.child,
    required this.enabled,
  });

  @override
  State<ViewMountTransition> createState() => _ViewMountTransitionState();
}

class _ViewMountTransitionState extends State<ViewMountTransition>
    with SingleTickerProviderStateMixin {
  bool _isDisposed = false;
  bool _forceUnmountAnimation = false;

  late final AnimationController _controller;
  late final Animation<double> _mountScaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ),
      reverseDuration: const Duration(
        milliseconds: 200,
      ),
    );

    _mountScaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,

        /// NOTE: Zune has a quirk where the album grid would fade-in + scale after a moment.
        ///       Adding Interval here to delay half of the animation to have the "staggered" effect.
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.linear,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,

        /// NOTE: Zune has a quirk where the album grid would fade-in + scale after a moment.
        ///       Adding Interval here to delay half of the animation to have the "staggered" effect.
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.linear,
      ),
    );

    /// NOTE: By default, starting the _controller MOUNT animations for
    ///       last selected music category. Global state will have default set as
    ///       albums.
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
            parent.MusicPlayerAnimationProvider.of(context);

        musicPlayerAnimationContext?.register(
          parent.EventType.unmountEvent,
          () async {
            /// NOTE: This logic is responsible for performing unmounting animation.
            ///       First check if the widget is not yet disposed in order to reverse
            ///       _controller and update the animation type to be mount.
            if (!_isDisposed) {
              setState(() {
                _forceUnmountAnimation = true;
              });
              await _controller.reverse();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.enabled || _forceUnmountAnimation
          ? _opacityAnimation
          : const AlwaysStoppedAnimation<double>(1.0),
      child: ScaleTransition(
        scale: widget.enabled || _forceUnmountAnimation
            ? _mountScaleAnimation
            : const AlwaysStoppedAnimation<double>(1.0),
        child: widget.child,
      ),
    );
  }
}
