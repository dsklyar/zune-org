part of window_bar_widget;

class WindowBar extends StatelessWidget {
  const WindowBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      color: const Color.fromARGB(25, 255, 249, 231),
      child: WindowTitleBarBox(
        child: MoveWindow(
            // child: GestureDetector(
            //   onTap: () => context.go(ApplicationRoute.home.route),
            //   child: const Icon(Icons.home),
            // ),
            ),
      ),
    );
  }
}
