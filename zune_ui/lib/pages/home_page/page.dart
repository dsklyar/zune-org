import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/main_menu/index.dart';
import 'package:zune_ui/widgets/support_menu/index.dart';

enum MenuType {
  support,
  main,
}

class HomePage extends StatefulWidget {
  final Size size;
  final bool isDebug;
  const HomePage({
    super.key,
    required this.size,
    required this.isDebug,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _unmountController;

  late final Widget mainMenuContent;
  late final Widget supportMenuContent;

  late final Animation<double> _supportMenuTransformAnimation;
  late final Animation<double> _supportMenuHeightAnimation;
  late final Animation<double> _mainMenuTransformAnimation;
  late final Animation<double> _mainMenuHeightAnimation;

  late final Animation<double> _rotationYAnimation;

  final GlobalKey mainMenuKey = GlobalKey(debugLabel: "main-menu");
  final GlobalKey supportMenuKey = GlobalKey(debugLabel: "support-menu");

  MenuType focusedMenu = MenuType.main;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _unmountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    mainMenuContent = const MainMenu();
    supportMenuContent = const SupportMenu();

    _rotationYAnimation = Tween(
      begin: 0.0,
      end: 1.4,
    ).animate(
      CurvedAnimation(
        parent: _unmountController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );

    _mainMenuTransformAnimation = Tween(
      begin: 1.0,
      end: 0.4,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );
    _mainMenuHeightAnimation = Tween(
      end: 1000.0,
      begin: 450.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );
    _supportMenuHeightAnimation = Tween(
      end: 450.0,
      begin: 1204.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );
    _supportMenuTransformAnimation = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _unmountController.dispose();
    super.dispose();
  }

  Widget generateView(BuildContext context) {
    Widget supportMenuHitBox = Listener(
      onPointerDown: focusedMenu == MenuType.main
          ? (event) => onTap(MenuType.support)
          : null,
      child: Container(
        width: 64,
        height: 348,
        // Need decoration for events to trigger
        decoration: const BoxDecoration(
          color: Colors.translucent,
        ),
      ),
    );

    Widget mainMenuHitBox = Listener(
      onPointerDown: focusedMenu == MenuType.support
          ? (event) => onTap(MenuType.main)
          : null,
      child: Container(
        width: 80,
        height: _supportMenuHeightAnimation.value,
        // Need decoration for events to trigger
        decoration: const BoxDecoration(
          color: Colors.translucent,
        ),
      ),
    );

    Widget mainMenu = Transform(
      key: mainMenuKey,
      transform: Matrix4.identity()..scale(_mainMenuTransformAnimation.value),
      alignment: FractionalOffset.centerRight,
      child: OverflowBox(
        maxHeight: _mainMenuHeightAnimation.value,
        child: AbsorbPointer(
          // Absorb Pointer in order to prevent scroll and hover effects
          absorbing: focusedMenu == MenuType.support,
          child: mainMenuContent,
        ),
      ),
    );

    Widget supportMenu = Transform(
      key: supportMenuKey,
      // NOTE:
      // Magical offset to place support manu under the play button of main menu
      origin: const Offset(0.0, 60.0),
      transform: Matrix4.identity()
        ..scale(_supportMenuTransformAnimation.value),
      alignment: FractionalOffset.centerLeft,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        maxWidth: 192,
        maxHeight: _supportMenuHeightAnimation.value,
        child: AbsorbPointer(
          // Absorb Pointer in order to prevent scroll and hover effects
          absorbing: focusedMenu == MenuType.main,
          child: supportMenuContent,
        ),
      ),
    );

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0009) // Perspective effect
        ..rotateY(_rotationYAnimation.value),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: focusedMenu == MenuType.main
            ? Alignment.bottomLeft
            : Alignment.centerRight,
        children: [
          focusedMenu == MenuType.main ? supportMenu : mainMenu,
          focusedMenu == MenuType.main ? mainMenu : supportMenu,
          if (focusedMenu == MenuType.main) supportMenuHitBox,
          if (focusedMenu == MenuType.support) mainMenuHitBox,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.isDebug ? widget.size.height - 30 : widget.size.height,
      decoration: const BoxDecoration(
          // color: Color.fromARGB(121, 238, 3, 81),
          ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return generateView(context);
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
