part of overlays_page;

class OverlaysPage extends StatefulWidget {
  final Size size;
  final Widget child;
  const OverlaysPage({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage>
    with TickerProviderStateMixin {
  late final AnimationController _controlsPageAnimationController;
  late final AnimationController _searchIndexPagAnimationController;

  final OverlayPortalController _splashPageOverlayController =
      OverlayPortalController();
  final OverlayPortalController _controlsPageOverlayController =
      OverlayPortalController();
  final OverlayPortalController _searchIndexPageOverlayController =
      OverlayPortalController();

  SearchIndexConfig _searchIndexConfig = {};

  @override
  void initState() {
    super.initState();

    _controlsPageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _searchIndexPagAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashPageOverlayController.show();
    });
  }

  @override
  void dispose() {
    _controlsPageAnimationController.dispose();
    _searchIndexPagAnimationController.dispose();
    super.dispose();
  }

  /// Handler responsible for controlling OverlayPortal's closing behavior
  /// 1. If handler needs to be closed without animation, use "fastClose" parameter
  /// 2. If controller is animating the closing effect, reset opacity to 100%
  /// 3. Otherwise, forward animation to 0% opacity, hide the Overlay
  ///    and reset the animation controller for future use
  void _closeControlsPageOverlay({bool? fastClose = false}) {
    if (fastClose == true) {
      _controlsPageOverlayController.hide();
      return;
    }
    if (_controlsPageAnimationController.isAnimating) {
      _controlsPageAnimationController.reset();
    } else {
      _controlsPageAnimationController.forward().then((_) {
        _controlsPageOverlayController.hide();
        _controlsPageAnimationController.reset();
      });
    }
  }

  void _closeSearchIndexPageOverlay() {
    _searchIndexPagAnimationController.forward().then((_) {
      _searchIndexPageOverlayController.hide();
      _searchIndexPagAnimationController.reset();
    });
  }

  void _showOverlay(OverlayType type) {
    switch (type) {
      case OverlayType.controls:
        _controlsPageOverlayController.show();
      case OverlayType.splash:
        _splashPageOverlayController.show();
      case OverlayType.searchIndex:
        _searchIndexPageOverlayController.show();
    }
  }

  void _setSearchTileConfig(SearchIndexConfig configuration) {
    _searchIndexConfig = configuration;
  }

  @override
  Widget build(BuildContext context) {
    return OverlaysProvider(
      showOverlay: _showOverlay,
      setSearchTileConfig: _setSearchTileConfig,
      child: Stack(
        children: [
          OverlayPortal(
            controller: _searchIndexPageOverlayController,
            overlayChildBuilder: (context) => SearchIndexPage(
              closeOverlayHandler: _closeSearchIndexPageOverlay,
              parentController: _searchIndexPagAnimationController,
              configuration: _searchIndexConfig,
            ),
          ),
          OverlayPortal(
            controller: _splashPageOverlayController,
            overlayChildBuilder: (context) =>
                SplashPage(size: widget.size, isDebug: isDebug),
          ),
          OverlayPortal(
            controller: _controlsPageOverlayController,
            overlayChildBuilder: (context) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(
                    parent: _controlsPageAnimationController,
                    curve: Curves.easeInExpo,
                  ),
                ),
                child: ControlsPage(
                  closeOverlayHandler: _closeControlsPageOverlay,
                  parentController: _controlsPageAnimationController,
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}
