part of common;

class MenuItemWrapper extends StatefulWidget {
  final Size size;
  final Offset startingOffset;
  final String displayText;
  final Widget child;
  final void Function() onTapHandler;
  const MenuItemWrapper({
    super.key,
    required this.child,
    required this.startingOffset,
    required this.displayText,
    required this.size,
    required this.onTapHandler,
  });

  @override
  State<MenuItemWrapper> createState() => _MenuItemWrapperState();
}

class _MenuItemWrapperState extends State<MenuItemWrapper>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fontSizeAnimation;
  late final Animation<Offset> _lerpToPositionAnimation;

  /// TODO: Maybe there a simpler way of doing this delay without debouncer,
  ///       such that, it can be tweaked via animation to be complete removed if user wants faster feel to UI.
  /// NOTE: Zune has a quirk, possibly because of a slow SOC, when user taps on menu header
  ///       to return to previous menu, there is a delay/lag with font color change.
  ///       Adding this debouncer tp modify state ["_menuHasBeenTapped"] below to change
  ///       font color to white for about 100ms before triggering the rest of the animation chain.
  final Debouncer _tapColorChangeDebouncer =
      Debouncer(duration: const Duration(milliseconds: 100));
  bool _menuHasBeenTapped = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fontSizeAnimation = Tween(
      begin: 42.0,
      end: 164.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
    );

    _lerpToPositionAnimation =
        Tween<Offset>(begin: widget.startingOffset, end: const Offset(-24, -74))
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapHandler() {
    /// NOTE: Zune has a quirk, possibly because of a slow SOC, when user taps on menu header
    ///       to return to previous menu, there is a delay/lag with font color change.
    ///       Adding this debouncer tp modify state ["_menuHasBeenTapped"] below to change
    ///       font color to white for about 100ms before triggering the rest of the animation chain.
    setState(() {
      _menuHasBeenTapped = true;
    });
    _tapColorChangeDebouncer.call(() {
      _controller.reverse();
      widget.onTapHandler();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Positioned(
              left: _lerpToPositionAnimation.value.dx,
              top: _lerpToPositionAnimation.value.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onTapHandler,
                child: Text(
                  widget.displayText,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: _menuHasBeenTapped ? Colors.white : Colors.gray,
                    fontSize: _fontSizeAnimation.value,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
