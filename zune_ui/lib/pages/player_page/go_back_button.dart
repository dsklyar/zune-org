part of player_page;

class GoBackButton extends StatelessWidget {
  final void Function() callback;
  const GoBackButton({
    super.key,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..translate(-7.0, -10.0, 0.0),
      child: OnTapDecorator(
        decorationBuilder: (isTapped) => BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isTapped
              ? [
                  const BoxShadow(
                    blurStyle: BlurStyle.outer,
                    color: Colors.white,
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        builder: (isTapped) => const CircleWidget(
          size: 56,
          borderWidth: 4,
          child: Icon(
            Icons.arrow_back_sharp,
            color: Colors.white,
            size: 44,
          ),
        ),
        onTapHandler: callback,
      ),
    );
  }
}
