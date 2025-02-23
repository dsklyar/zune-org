part of view_selector_widget;

class ViewSlideTransition extends StatefulWidget {
  final Widget child;
  final MusicCategoryType activeCategory;

  const ViewSlideTransition({
    Key? key,
    required this.child,
    required this.activeCategory,
  }) : super(key: key);

  @override
  State<ViewSlideTransition> createState() => _ViewSlideTransitionState();
}

class _ViewSlideTransitionState extends State<ViewSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  AnimationType _currentAnimationType = AnimationType.mount;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant ViewSlideTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCategory != widget.activeCategory) {
      final categoryDelta = MusicCategoryType.getMusicDeltaChange(
        oldWidget.activeCategory,
        widget.activeCategory,
      );

      _currentAnimationType =
          AnimationType.deriveCurrentAnimationType(categoryDelta);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<Offset> deriveSlideAnimation() {
    /// NOTE: Stop slide animation if ViewSelector widget is mounting first View.
    if (_currentAnimationType == AnimationType.mount) {
      return const AlwaysStoppedAnimation<Offset>(Offset.zero);
    }
    return Tween<Offset>(
      begin: _currentAnimationType.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  Animation<double> deriveFadeAnimation() {
    /// NOTE: Stop slide animation if ViewSelector widget is mounting first View.
    if (_currentAnimationType == AnimationType.mount) {
      return const AlwaysStoppedAnimation<double>(1.0);
    }
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeTransition(
        opacity: deriveFadeAnimation(),
        child: SlideTransition(
          position: deriveSlideAnimation(),
          child: widget.child,
        ),
      ),
    );
  }
}
