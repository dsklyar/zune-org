library overlays_page;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:zune_ui/pages/controls_page/page.dart';
import 'package:zune_ui/pages/splash_page/page.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "wrapper.dart";

const initialSize = Size(272, 480);
const isDebug = kDebugMode;

final console = DebugPrint().register(DebugComponent.overlaysPage);

class OverlaysPage extends StatefulWidget {
  final Size size;
  final Widget child;
  const OverlaysPage({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _controlsPageAnimationController;
  final OverlayPortalController _splashPageOverlayController =
      OverlayPortalController();
  final OverlayPortalController _controlsPageOverlayController =
      OverlayPortalController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controlsPageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashPageOverlayController.show();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handler responsible for controlling OverlayPortal's closing behavior
  /// 1. If handler needs to be closed without animation, use "fastClose" parameter
  /// 2. If controller is animating the closing effect, reset opacity to 100%
  /// 3. Otherwise, forward animation to 0% opacity, hide the Overlay
  ///    and reset the animation controller for future use
  void _closeControlsPageOverlay({bool? fastClose = false}) {
    if (fastClose == true) {
      _controlsPageOverlayController.hide();
      return;
    }
    if (_controlsPageAnimationController.isAnimating) {
      _controlsPageAnimationController.reset();
    } else {
      _controlsPageAnimationController.forward().then((_) {
        _controlsPageOverlayController.hide();
        _controlsPageAnimationController.reset();
      });
    }
  }

  void _showOverlay(OverlayType type) {
    switch (type) {
      case OverlayType.controls:
        _controlsPageOverlayController.show();
      case OverlayType.splash:
        _splashPageOverlayController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaysProvider(
      showOverlay: _showOverlay,
      child: Stack(
        children: [
          OverlayPortal(
            controller: _splashPageOverlayController,
            overlayChildBuilder: (context) =>
                SplashPage(size: widget.size, isDebug: isDebug),
          ),
          OverlayPortal(
            controller: _controlsPageOverlayController,
            overlayChildBuilder: (context) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(
                    parent: _controlsPageAnimationController,
                    curve: Curves.easeInExpo,
                  ),
                ),
                child: ControlsPage(
                  closeOverlayHandler: _closeControlsPageOverlay,
                  parentController: _controlsPageAnimationController,
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}
