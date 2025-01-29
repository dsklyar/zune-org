part of player_page;

class ReturnButton extends StatefulWidget {
  const ReturnButton({super.key});

  @override
  State<ReturnButton> createState() => _ReturnButtonState();
}

class _ReturnButtonState extends State<ReturnButton> {
  bool _isTapped = false;

  void _onTapDown(TapDownDetails details) => setState(() {
        _isTapped = true;
      });

  void _onTapUp() => setState(() {
        _isTapped = false;
      });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..translate(-7.0, -10.0, 0.0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: (_) => _onTapUp,
        onTapCancel: _onTapUp,
        onTap: () {
          context.go(ApplicationRoute.home.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isTapped
                ? [
                    const BoxShadow(
                      blurStyle: BlurStyle.outer,
                      color: Colors.white,
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: const CircleWidget(
            size: 56,
            borderWidth: 4,
            child: Icon(
              Icons.arrow_back_sharp,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}
