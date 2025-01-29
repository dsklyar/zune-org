library splash_page;

import 'dart:async';

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

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
  double _yOffset = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      final temp = details.delta.dy + _yOffset;
      const lowerBound = 0;
      final upperBound =
          (-(widget.isDebug ? widget.size.height - 30 : widget.size.height) +
              16);
      if (temp <= lowerBound && temp >= upperBound) {
        _yOffset += details.delta.dy;
      }
      // console.log(_yOffset);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_yOffset.abs() > widget.size.height * .2) {
      _animateOffset(-widget.size.height);
    } else {
      _animateOffset(0);
    }
  }

  void _animateOffset(double endOffset) {
    final animation =
        Tween<double>(begin: _yOffset, end: endOffset).animate(_controller);

    void listener() {
      setState(() {
        _yOffset = animation.value;
      });
    }

    animation.addListener(listener);

    // Start animation
    _controller.forward().then((_) {
      setState(() {
        animation.removeListener(listener);
        _controller.reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0, _yOffset),
          child: Container(
            width: widget.size.width,
            height:
                widget.isDebug ? widget.size.height - 30 : widget.size.height,
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
                  child: const Center(
                    heightFactor: 0.5,
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
