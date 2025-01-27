part of player_page;

class ReturnButton extends StatelessWidget {
  const ReturnButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..translate(-7.0, -10.0, 0.0),
      child: CircleWidget(
          size: 56,
          borderWidth: 4,
          child: const Icon(
            Icons.arrow_back_sharp,
            color: Colors.white,
            size: 44,
          ),
          cb: () {
            context.go("/");
          }),
    );
  }
}
