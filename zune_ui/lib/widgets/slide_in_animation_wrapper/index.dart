import 'package:flutter/material.dart';

class SlideInAnimationWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const SlideInAnimationWrapper({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.offset = const Offset(0.0, 0.0),
  }) : super(key: key);

  @override
  State<SlideInAnimationWrapper> createState() =>
      _SlideInAnimationWrapperState();
}

class _SlideInAnimationWrapperState extends State<SlideInAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isMounted = true; // Flag to track if the widget is mounted

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Define the slide animation
    _animation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero, // End position is the original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Prevent controller trigger when component is unmounted
    if (_isMounted) {
      // Start the slide-in animation
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    _isMounted = false;
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
