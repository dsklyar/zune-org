part of player_page;

class PlayerPage extends StatefulWidget {
  final Size size;
  const PlayerPage({
    super.key,
    required this.size,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = Tween(
      begin: 0.0,

      /// NOTE: This value makes the transform almost orthogonal to the viewing plane
      end: -1.55,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
    );

    /// Reuse animation above by setting controller to end value
    _controller.value = 1;
    _controller.reverse();
  }

  void onBackClick() {
    _controller.forward().then((_) {
      context.go(ApplicationRoute.home.route);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// NOTE: This provider exposes all of the overlays in the app
    final overlaysProvider = OverlaysProvider.of(context);

    /// NOTE: Very curious thing here:
    ///       If I change this to SizedBox and remove decoration,
    ///       the windows system will play notification sound when clicking on background of said box
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: Tween<double>(begin: 1, end: 0).animate(_controller).value,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0009) // Perspective effect
            ..rotateY(_animation.value),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: Colors.transparent,
            child: Consumer<GlobalModalState>(
              builder: (context, state, child) {
                if (state.currentlyPlaying == null) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  children: [
                    if (state.currentlyPlaying!.album.album_illustration !=
                        null)
                      Positioned.fill(
                        child: Opacity(
                          opacity: Tween<double>(begin: 1, end: 0)
                              .animate(_controller)
                              .value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0009)
                              ..translate(0.0, 0.0, -50.0)
                              ..scale(0.95),
                            child: Image.memory(
                              state.currentlyPlaying!.album.album_illustration!,
                              fit: BoxFit.cover,
                              color: const Color.fromARGB(150, 0, 0, 0),
                              colorBlendMode: BlendMode.darken,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoBackButton(
                          callback: onBackClick,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 32),
                          child: Column(
                            // Make artist/album title align from left side
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.currentlyPlaying!.album.artist_name
                                    .toUpperCase(),
                                style: Styles.albumArtist,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                              ),
                              Text(
                                state.currentlyPlaying!.album.album_name
                                    .toUpperCase(),
                                style: Styles.albumTitle,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              // Make song title align from left side
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CurrentTrackTile(
                                  showOverlay: () => overlaysProvider!
                                      .showOverlay(OverlayType.controls),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    state.currentlyPlaying!.song.track_name,
                                    style: Styles.songTitle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 40,
                                  ),
                                  child: Consumer<GlobalModalState>(
                                    builder: (context, state, child) {
                                      final songs = state.getNext3Songs();
                                      if (songs.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: state
                                              .getNext3Songs()
                                              .map((e) => Text(
                                                    e.track_name,
                                                    style: Styles.listItem,
                                                  ))
                                              .toList());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const TrackActionsControls(),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
