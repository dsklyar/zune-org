part of common;

class OnTapDecorator extends StatefulWidget {
  final void Function() onTapHandler;
  final BoxDecoration Function(bool isTapped) decorationBuilder;
  final Widget Function(bool isTapped) builder;

  const OnTapDecorator({
    super.key,
    required this.decorationBuilder,
    required this.builder,
    required this.onTapHandler,
  });

  @override
  State<OnTapDecorator> createState() => _OnTapDecoratorState();
}

class _OnTapDecoratorState extends State<OnTapDecorator> {
  bool _isTapped = false;

  void _onTapDown(TapDownDetails details) => setState(() {
        _isTapped = true;
      });

  void _onTapUp() => setState(() {
        _isTapped = false;
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _onTapUp,
      onTapCancel: _onTapUp,
      onTap: widget.onTapHandler,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: widget.decorationBuilder(_isTapped),
        child: widget.builder(_isTapped),
      ),
    );
  }
}
