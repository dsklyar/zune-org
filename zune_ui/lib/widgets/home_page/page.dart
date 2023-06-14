import 'package:flutter/widgets.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:zune_ui/widgets/main_menu/index.dart';
import 'package:zune_ui/widgets/support_menu/menu.dart';
import 'dart:io';

enum MenuType {
  support,
  main,
}

class AnimatedHomePage extends StatefulWidget {
  final Size size;
  final bool isDebug;
  const AnimatedHomePage({
    super.key,
    required this.size,
    required this.isDebug,
  });

  @override
  State<AnimatedHomePage> createState() => _AminatedHomePageState();
}

class _AminatedHomePageState extends State<AnimatedHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Size?> _supportMenuSizeAnimation;
  late final Animation<double> _supportMenuLeftAnimation = Tween(
    begin: -88.0,
    end: 0.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeIn,
    ),
  );
  late final Animation<double> _supportMenuTransformAnimation = Tween(
    begin: 0.3,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  late final Animation<double> _mainMenuRightAnimation = Tween(
    begin: 0.0,
    end: -44.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeIn,
    ),
  );
  late final Animation<double> _mainMenuTransformAnimation = Tween(
    begin: 1.0,
    end: .5,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  MenuType focusedMenu = MenuType.main;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _supportMenuSizeAnimation = SizeTween(
      begin: Size(
        64,
        widget.size.height,
      ),
      end: Size(
        widget.size.width - 64,
        widget.size.height,
      ),
    )
        .chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        )
        .animate(_controller);
  }

  // @override
  // void didUpdateWidget(AnimatedHomePage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _controller.duration = widget.duration;
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> generateStack(BuildContext context) {
    List<Widget> widgetList = [];

    Widget supportMenuPanel = Positioned(
      left: 0,
      child: TransparentPointer(
        child: Listener(
          onPointerDown: focusedMenu == MenuType.main
              ? (event) => onTap(MenuType.support)
              : null,
          child: Opacity(
            opacity: _supportMenuTransformAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(123, 30, 248, 59),
              ),
              height: _supportMenuSizeAnimation.value!.height,
              width: _supportMenuSizeAnimation.value!.width,
            ),
          ),
        ),
      ),
    );

    Widget supportMenu = Positioned(
      left: _supportMenuLeftAnimation.value,
      height: widget.size.height,
      width: widget.size.width,
      child: ClipRect(
        child: ScaleTransition(
          scale: _supportMenuTransformAnimation,
          child: OverflowBox(
            maxHeight:
                widget.size.height * (1 / _supportMenuTransformAnimation.value),
            child: const SupportMenu(),
          ),
        ),
      ),
    );

    Widget mainMenuPanel = Positioned(
      right: 0,
      child: TransparentPointer(
        child: Listener(
          onPointerDown: focusedMenu == MenuType.support
              ? (event) => onTap(MenuType.main)
              : null,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(96, 255, 255, 255),
            ),
            height: _supportMenuSizeAnimation.value!.height,
            width: widget.size.width - _supportMenuSizeAnimation.value!.width,
          ),
        ),
      ),
    );

    Widget mainMenu = Positioned(
      right: _mainMenuRightAnimation.value,
      height: widget.size.height,
      width: widget.size.width,
      child: Opacity(
        opacity: _mainMenuTransformAnimation.value,
        child: ScaleTransition(
          scale: _mainMenuTransformAnimation,
          alignment: Alignment.centerRight,
          child: OverflowBox(
            alignment: Alignment.center,
            maxHeight:
                widget.size.height * (1 / _mainMenuTransformAnimation.value),
            child: const MainMenu(),
          ),
        ),
      ),
    );

    widgetList.addAll([
      focusedMenu == MenuType.main ? supportMenu : mainMenu,
      focusedMenu == MenuType.main ? mainMenu : supportMenu,
      focusedMenu == MenuType.main ? supportMenuPanel : mainMenuPanel,
      focusedMenu == MenuType.main ? mainMenuPanel : supportMenuPanel,
    ]);

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.isDebug ? widget.size.height - 30 : widget.size.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: generateStack(context),
          );
        },
      ),
    );
  }

  void onTap(MenuType type) {
    stderr.writeln('$type');
    if (focusedMenu == MenuType.main) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      focusedMenu = type;
    });
  }
}
