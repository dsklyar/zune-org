part of player_page;

class CurrentTrackTile extends StatefulWidget {
  final void Function() showOverlay;
  const CurrentTrackTile({
    super.key,
    required this.showOverlay,
  });

  @override
  State<CurrentTrackTile> createState() => _CurrentTrackTileState();
}

class _CurrentTrackTileState extends State<CurrentTrackTile>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  double _offset = 0.0; // Track the offset of AlbumTile

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragCancel() {
    setState(() {
      _offset = 0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      final temp = (_offset + details.delta.dx).toInt();

      // TODO: fix magical numbers for width
      if (temp <= 272 && temp >= -272) {
        _offset += details.delta.dx.toInt();
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // FocusScope.of(context).unfocus();
    final globalState = context.read<GlobalModalState>();
    console.log("----->$_offset, ${272 / 4}");

    // TODO: Fix magical numbers
    if (_offset > (272 / 4)) {
      console.log("User swiped right, playing previous song",
          customTags: ["track controls"]);

      globalState.playNextPrevSong(-1);
      _animateOffset(272);
    } else if (_offset < -(272 / 4)) {
      console.log("User swiped left, playing next song",
          customTags: ["track controls"]);

      globalState.playNextPrevSong(1);
      _animateOffset(-272);
    } else {
      _animateOffset(0);
    }
  }

  void _animateOffset(double endOffset) {
    // Animate to the new offset
    _controller.reset();

    if (_offset.toInt() == 0) {
      return;
    }

    // Set up animation from current offset to target offset
    final animation =
        Tween<double>(begin: _offset, end: endOffset).animate(_controller);

    void listener() {
      setState(() {
        _offset = animation.value;
      });
    }

    animation.addListener(listener);

    // Start animation
    _controller.forward().then((_) {
      setState(() {
        animation.removeListener(listener);
        // Reset offset after animation completes
        _offset = 0.0;
        // Reset controller for future animations
        _controller.reset();
      });
    });
  }

  /// TODO: This is a jank function, which only supports formatting to minutes,
  ///       edge case can be an hour long podcast
  String getTime(int input) {
    final total = (input / 60).toInt();
    final remTemp = input % 60;
    final remPrint = remTemp < 10 ? "0$remTemp" : "$remTemp";
    return "$total:$remPrint";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      child: SizedBox(
        /// Specifying the maximum width so that there will be space for next/prev song action
        /// Align will take care of positioning the SizedBox with largeTileWidth correctly
        width: double.maxFinite,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: TileUtility.largeTileWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Selector<GlobalModalState, SongModel>(
                  selector: (context, state) => state.currentlyPlaying!.song,
                  builder: (context, track, child) => Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(
                          -MediaQuery.of(context).size.width + _offset,
                          0,
                        ),
                        child: TrackTile(
                          track: track,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(_offset, 0),
                        child: TrackTile(
                          track: track,
                          onTap: widget.showOverlay,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                          MediaQuery.of(context).size.width + _offset,
                          0,
                        ),
                        child: TrackTile(
                          track: track,
                        ),
                      ),
                    ],
                  ),
                ),
                Selector<GlobalModalState, int>(
                  selector: (context, state) =>
                      state.currentlyPlaying!.song.duration!,
                  builder: (context, duration, child) {
                    return StreamBuilder(
                      stream: SeekChange.rustSignalStream,
                      builder: (context, snapshot) {
                        final rustSignal = snapshot.data;

                        final currentTime =
                            rustSignal?.message.currentSeekValue ?? 0;
                        final endsInTime = duration - currentTime;
                        final progressWidth = (currentTime / duration) *
                            TileUtility.largeTileWidth;

                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 2,
                                  width: progressWidth,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(
                                      top: 2.0, bottom: 4.0),
                                ),
                                Container(
                                  height: 2,
                                  width: double.maxFinite,
                                  color: Colors.white.withAlpha(50),
                                  margin: const EdgeInsets.only(
                                      top: 2.0, bottom: 4.0),
                                ),
                              ],
                            ),
                            Row(
                              // Space between the timestamps
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTime(currentTime),
                                  style: Styles.timestamp,
                                ),
                                Text(
                                  "-${getTime(endsInTime)}",
                                  style: Styles.timestamp,
                                )
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
