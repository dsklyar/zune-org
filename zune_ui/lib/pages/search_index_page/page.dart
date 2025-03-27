part of search_index_page;

typedef SearchIndexConfig = Map<String, Future<void> Function()>;

class SearchIndexPage extends StatefulWidget {
  final AnimationController parentController;
  final void Function() closeOverlayHandler;

  final SearchIndexConfig configuration;

  const SearchIndexPage({
    super.key,
    required this.closeOverlayHandler,
    required this.parentController,
    required this.configuration,
  });

  @override
  State<SearchIndexPage> createState() => _SearchIndexPageState();
}

class _SearchIndexPageState extends State<SearchIndexPage>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _slideOutYOffsetAnimation;
  final Debouncer _autoCloseDebouncer = Debouncer(
    duration: const Duration(seconds: 5),
    debugName: "search-index-auto-close-effect",
    logger: console,
  );

  // bool _panelIsInUse = false;

  @override
  void initState() {
    super.initState();

    _slideOutYOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 480, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -480)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
    ]).animate(widget.parentController);

    _triggerInitialAnimation();
  }

  @override
  void dispose() {
    _autoCloseDebouncer.cancel();
    super.dispose();
  }

  void _triggerInitialAnimation() =>
      widget.parentController.animateTo(0.5).then(
            (_) => _animateAutoClose(),
          );

  void _animateAutoClose({bool forceAnimate = false}) {
    // AutoClose animation dispatch callback
    dispatch() => widget.parentController
        .forward(from: 0.5)
        .then((_) => widget.closeOverlayHandler());
    // Skip debounce
    if (forceAnimate) {
      dispatch();
    } else {
      _autoCloseDebouncer.call(dispatch);
    }
  }

  /// NOTE: This method is responsible for executing the animate to
  ///       callback if the groupKey is present in the configuration
  ///       dictionary. If present, force execute the auto close animation
  ///       and execute the callback.
  void _onSearchIndexTileTapHandler(String groupKey) {
    if (widget.configuration.containsKey(groupKey)) {
      _animateAutoClose(forceAnimate: true);
      widget.configuration[groupKey]!();
    }
  }

  /// NOTE: Capture taps which do not result into scroll animation
  ///       and debounce the auto close animation.
  void _handleUnrelatedTap() => _animateAutoClose();

  /// NOTE: This method is responsible for closing the search index page
  ///       via force animation.
  void _handleExitTap() => _animateAutoClose(forceAnimate: true);

  @override
  Widget build(BuildContext context) {
    const indexKey = " #abcdefghijklmnopqrstuvwxyz";

    return AnimatedBuilder(
      animation: _slideOutYOffsetAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideOutYOffsetAnimation.value),
        child: GestureDetector(
          onTap: _handleUnrelatedTap,
          child: Container(
            padding: const EdgeInsets.only(top: 8),
            color: Colors.black.withAlpha(250),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: indexKey.length,
              itemBuilder: (context, index) => index == 0
                  ? GestureDetector(
                      onTap: _handleExitTap,
                      child: Text(
                        "exit".toUpperCase(),
                        style: Styles.exitLabel,
                      ),
                    )
                  : SearchIndexTile(
                      index: indexKey[index],
                      isDisabled:
                          !widget.configuration.containsKey(indexKey[index]),
                      onTap: () =>
                          _onSearchIndexTileTapHandler(indexKey[index]),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
