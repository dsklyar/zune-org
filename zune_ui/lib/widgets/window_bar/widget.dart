part of window_bar_widget;

class WindowBar extends StatelessWidget {
  final GoRouter? router;
  const WindowBar({
    super.key,
    this.router,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      color: const Color.fromARGB(50, 255, 249, 231),
      child: WindowTitleBarBox(
        child: MoveWindow(
            child: Row(
          children: [
            router != null
                ? GestureDetector(
                    onTap: () => router?.go(ApplicationRoute.home.route),
                    child: const Icon(Icons.home),
                  )
                : const SizedBox.shrink(),
          ],
        )),
      ),
    );
  }
}
