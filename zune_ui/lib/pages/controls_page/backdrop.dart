part of controls_page;

class Backdrop extends StatelessWidget {
  const Backdrop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 0.8,
                colors: [
                  Color.fromARGB(0, 0, 0, 0), // Vignette effect
                  Color.fromARGB(0, 0, 0, 0),
                  Color.fromARGB(250, 0, 0, 0),
                ],
              ),
            ),
          ),
        ),
        // This is the backdrop filter to reduce opacity
        Positioned.fill(
          // Semi-transparent background
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
