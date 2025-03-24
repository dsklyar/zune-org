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
    duration: const Duration(seconds: 2),
    debugName: "auto-close-effect",
    logger: console,
  );

  // bool _panelIsInUse = false;

  @override
  void initState() {
    super.initState();

    // console.log("render me");

    _slideOutYOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 480, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -480)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 1,
      ),
    ]).animate(widget.parentController);

    _triggerInitialAnimation();
  }

  void _triggerInitialAnimation() {
    // widget.parentController.animateTo(0.5).then(
    //       (_) => _triggerDebouncer(),
    //     );
    widget.parentController.animateTo(0.5);
  }

  void _animateAutoClose() {
    // Start animation
    widget.parentController.forward(from: 0.5).then((_) {
      widget.closeOverlayHandler();
      // setState(() {
      //   // widget.parentController.reset();
      //   // _panelIsInUse = false;
      // });
    });
  }

  void _triggerDebouncer() {
    /// NOTE: Abstraction to trigger bounce animation delayed by the debouncer
    _autoCloseDebouncer.call(() => _animateAutoClose());
  }

  void onSearchIndexTileTapHandler(String groupKey) {
    if (widget.configuration.containsKey(groupKey)) {
      final action = widget.configuration[groupKey]!;
      _animateAutoClose();
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    const indexKey = " #abcdefghijklmnoprstuvwxyz.";

    return AnimatedBuilder(
      animation: _slideOutYOffsetAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideOutYOffsetAnimation.value),
        child: GestureDetector(
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
                  ? Text(
                      "exit".toUpperCase(),
                      style: Styles.exitLabel,
                    )
                  : SearchIndexTile(
                      index: indexKey[index],
                      onTap: () => onSearchIndexTileTapHandler(indexKey[index]),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
