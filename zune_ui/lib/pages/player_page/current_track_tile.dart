part of player_page;

class CurrentTrackTile extends StatefulWidget {
  final void Function() showOverlay;
  final double offset;
  const CurrentTrackTile({
    super.key,
    required this.showOverlay,
    this.offset = 0,
  });

  @override
  State<CurrentTrackTile> createState() => _CurrentTrackTileState();
}

class _CurrentTrackTileState extends State<CurrentTrackTile>
    with TickerProviderStateMixin {
  // TODO: Not sure if this animation controller is needed, there is nothing to animate here
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return SizedBox(
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
                        -MediaQuery.of(context).size.width + widget.offset,
                        0,
                      ),
                      child: TrackTile(
                        track: track,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(widget.offset, 0),
                      child: TrackTile(
                        track: track,
                        onTap: widget.showOverlay,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(
                        MediaQuery.of(context).size.width + widget.offset,
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
                      final progressWidth =
                          (currentTime / duration) * TileUtility.largeTileWidth;

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
    );
  }
}
