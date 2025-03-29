part of overlays_page;

enum OverlayType {
  controls,
  splash,
  searchIndex,
}

class OverlaysProvider extends InheritedWidget {
  final void Function(OverlayType type) showOverlay;
  final void Function(SearchIndexConfig configuration) setSearchTileConfig;

  const OverlaysProvider({
    Key? key,
    required this.showOverlay,
    required this.setSearchTileConfig,
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
