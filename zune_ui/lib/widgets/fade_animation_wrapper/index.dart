import 'package:flutter/material.dart';
import 'package:zune_ui/widgets/custom/time_utils.dart';

class FadeAnimationWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration? delayBeforeFadeOut;

  const FadeAnimationWrapper({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    // this.delayBeforeFadeOut = const Duration(milliseconds: 2000),
    this.delayBeforeFadeOut,
  }) : super(key: key);

  @override
  State<FadeAnimationWrapper> createState() => _FadeAnimationWrapperState();
}

class _FadeAnimationWrapperState extends State<FadeAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isMounted = true; // Flag to track if the widget is mounted
  Debouncer? _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _debouncer = widget.delayBeforeFadeOut != null
        ? Debouncer(duration: widget.delayBeforeFadeOut!, debugName: "-1")
        : null;
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startAnimation();
  }

  void _startAnimation() {
    // Colla forward once fade i nwas complted
    if (_controller.isDismissed) {
      _controller.forward();
    }
    // Check if delayBeforeFadeOut is provided
    if (widget.delayBeforeFadeOut != null) {
      // Start fade-out animation
      // TODO: this triggers a lot of new & cancelled timer creations
      _debouncer?.call(() {
        if (_isMounted) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FadeAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO: this triggers a lot of new & cancelled timer creations
    _startAnimation();
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
