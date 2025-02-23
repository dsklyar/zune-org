part of search_index_page;

class SearchIndexPage extends StatefulWidget {
  final AnimationController parentController;
  final void Function() closeOverlayHandler;

  const SearchIndexPage({
    super.key,
    required this.closeOverlayHandler,
    required this.parentController,
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

  @override
  void dispose() {
    super.dispose();
  }

  void _triggerInitialAnimation() {
    widget.parentController.animateTo(0.5).then(
          (_) => _triggerDebouncer(),
        );
  }

  void _animateAutoClose() {
    // Start animation
    widget.parentController.forward(from: 0.5).then((_) {
      widget.parentController.reset();
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

  @override
  Widget build(BuildContext context) {
    const indexKey = "#abcdefghijklmnoprstuvwxyz.";

    return AnimatedBuilder(
      animation: _slideOutYOffsetAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideOutYOffsetAnimation.value),
        child: GestureDetector(
          child: Container(
            color: Colors.black.withAlpha(250),
            // padding: const EdgeInsets.only(
            //     left: 12.0, right: 12.0, bottom: 12.0, top: 12),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                GestureDetector(
                  // Account for container's padding when doing test detection
                  behavior: HitTestBehavior.translucent,
                  // onTap: () => widget.closeOverlayHandler(fastClose: true),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 56,
                    height: 56,
                    child: Text(
                      "exit".toUpperCase(),
                      style: Styles.exitLabel,
                    ),
                  ),
                ),
                ...indexKey
                    .split("")
                    .map(
                      (index) => SearchIndexTile(
                        index: index,
                        onTap: () {},
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
