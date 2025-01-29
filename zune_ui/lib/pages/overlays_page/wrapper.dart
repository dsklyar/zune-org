part of overlays_page;

enum OverlayType {
  controls,
  splash,
}

class OverlaysProvider extends InheritedWidget {
  final void Function(OverlayType type) showOverlay;

  const OverlaysProvider({
    Key? key,
    required this.showOverlay,
    required Widget child,
  }) : super(key: key, child: child);

  static OverlaysProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OverlaysProvider>();
  }

  @override
  bool updateShouldNotify(OverlaysProvider oldWidget) {
    return true; // Update when the function changes if needed
  }
}
