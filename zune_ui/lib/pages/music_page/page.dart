part of music_page;

final console = DebugPrint().register(DebugComponent.musicPage);

class Styles {
  static const TextStyle titleFont = TextStyle(
    fontWeight: FontWeight.w300,
    color: Colors.gray,
    fontSize: 164,
    height: 1,
  );
  static const TextStyle subtitleFont = TextStyle(
    fontWeight: FontWeight.w400,
    color: Colors.gray,
    fontSize: 32,
    height: 1,
  );
  static const TextStyle tileFont = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 1,
  );
}

class MusicPage extends StatefulWidget {
  final Size size;
  final Offset startingOffset;
  const MusicPage({
    super.key,
    required this.startingOffset,
    required this.size,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fontSizeAnimation;
  late final Animation<Offset> _lerpToPositionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fontSizeAnimation = Tween(
      begin: 42.0,
      end: 164.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
    );

    _lerpToPositionAnimation =
        // Tween<Offset>(begin: widget.startingOffset, end: Offset.zero)
        Tween<Offset>(
                begin: Offset(0, widget.startingOffset.dy),
                end: const Offset(-24, -74))
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
    );

    console.log(widget.startingOffset.toString());
    _controller.forward();
  }

  Offset _deriveOffset(GlobalKey key) {
    // final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    // if (renderBox != null) {
    //   final widgetPosition = renderBox.localToGlobal(Offset.zero);
    //   final dif = _lerpToPositionAnimation.value - widgetPosition;
    //   console.log("-->${widget.startingOffset} - $widgetPosition = $dif");
    //   return dif;
    // }

    return _lerpToPositionAnimation.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _titleKey = GlobalKey();
    return AnimatedBuilder(
      animation:
          Listenable.merge([_lerpToPositionAnimation, _fontSizeAnimation]),
      builder: (context, child) => Container(
        width: widget.size.width,
        height: widget.size.height,
        color: Colors.transparent,

        /// NOTE: Column widget attempts to take all available space,
        ///       in order to mimic it use ListView
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => context.go(ApplicationRoute.home.route),
              child: SizedBox(
                height: 64,
                child: Transform.translate(
                  offset: _deriveOffset(_titleKey),
                  // offset: Offset(0,0),
                  child: Text(
                    key: _titleKey,
                    "music",
                    // style: TextStyle(fontSize: 42),
                    // style: Styles.titleFont,
                    style: Styles.titleFont
                        .copyWith(fontSize: _fontSizeAnimation.value),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
            ScrollConfiguration(
              // Disable scrollbar, but let scrolling
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    Text(
                      "albums".toUpperCase(),
                      style: Styles.subtitleFont,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      "artists".toUpperCase(),
                      style: Styles.subtitleFont,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      "playlists".toUpperCase(),
                      style: Styles.subtitleFont,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      "songs".toUpperCase(),
                      style: Styles.subtitleFont,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      "genres".toUpperCase(),
                      style: Styles.subtitleFont,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
            const AlbumsGrid(),
          ],
        ),
      ),
    );
  }
}
