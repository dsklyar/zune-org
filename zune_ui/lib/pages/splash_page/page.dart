library splash_page;

import 'dart:async';

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/time_utils.dart';

part "clock.dart";
part "font_styles.dart";

final console = DebugPrint().register(DebugComponent.splashPage);

class SplashPage extends StatefulWidget {
  final Size size;
  final bool isDebug;
  const SplashPage({
    super.key,
    required this.size,
    required this.isDebug,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;
  final Debouncer _bounceDebouncer = Debouncer(
    duration: const Duration(seconds: 5),
    debugName: "page-bounce-effect",
    logger: console,
  );
  bool _panelIsInUse = false;
  bool _isMounted = true;
  bool _isPanelDismissed = false;
  double _yOffset = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -50)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -50, end: -0)
            .chain(CurveTween(curve: Curves.bounceOut)),

        /// NOTE: Weight is 4 so that animation step is allocated for longer time
        weight: 4,
      ),
    ]).animate(_bounceController);

    _triggerBounce();
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails _) {
    setState(() {
      _panelIsInUse = true;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      final temp = details.delta.dy + _yOffset;
      const lowerBound = 0;
      final upperBound = (-widget.size.height + 16);
      if (temp <= lowerBound && temp >= upperBound) {
        _yOffset += details.delta.dy;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    /// NOTE: On drag end, call _animateOffset function to
    ///       1. Reset splash panel to bottom if the 20% of height threshold
    ///          was not reached.
    ///       2. Run the animation to swipe up the splash panel and marked
    ///          panel dismissed so that the bounce effect is not triggered
    if (_yOffset.abs() > widget.size.height * .2) {
      _animateOffset(-widget.size.height, setPanelDismissed: true);
    } else {
      _animateOffset(0);
    }
  }

  void _animateOffset(double endOffset, {bool setPanelDismissed = false}) {
    /// NOTE: Animate from current y offset to the end offset specified
    final animation =
        Tween<double>(begin: _yOffset, end: endOffset).animate(_controller);

    /// NOTE: Listener responsible for updating y offset as the animation executes
    void listener() {
      setState(() {
        _yOffset = animation.value;
      });
    }

    /// NOTE: Status listener responsible for resetting bounce effect
    ///       if reset splash panel animation is complete.
    /// TODO: THIS MIGHT HAVE AN EDGE CASE where the animation is not complete
    ///       and bounce effect executes
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _triggerBounce();
      }
    }

    animation.addListener(listener);
    animation.addStatusListener(statusListener);

    // Start animation
    _controller.forward().then((_) {
      setState(() {
        animation.removeListener(listener);
        animation.removeStatusListener(statusListener);
        _controller.reset();
        _panelIsInUse = false;

        if (setPanelDismissed) {
          _isPanelDismissed = true;
        }
      });
    });
  }

  void _animateBounce() {
    /// NOTE: If user is not interacting with splash panel
    ///       AND the widget is mounted
    ///       AND the splash panel is not already dismissed
    ///       trigger the bounce animation/controller.
    ///       Otherwise, if user has interacted with splash panel and not dismissed it
    ///       trigger the bounce debouncer again. If not, drop the function call.
    if (!_panelIsInUse && _isMounted && !_isPanelDismissed) {
      _bounceController.forward().then((_) {
        _bounceController.reset();
      });
    } else if (!_isPanelDismissed) {
      _triggerBounce();
    }
  }

  void _triggerBounce() {
    /// NOTE: Abstraction to trigger bounce animation delayed by the debouncer
    _bounceDebouncer.call(() => _animateBounce());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [
          _bounceController,
          _controller,
        ],
      ),
      builder: (context, child) => GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0, _yOffset + _bounceAnimation.value),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: SizedBox.shrink(),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Clock(),
                ),
                Container(
                  width: widget.size.width,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 212, 220, 228),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.none,
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 24,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
