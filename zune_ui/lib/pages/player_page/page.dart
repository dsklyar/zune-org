import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';

class Styles {
  static const TextStyle albumArtist = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1,
  );
  static const TextStyle albumTitle = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 32,
    height: 1,
  );
  static const TextStyle songTitle = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 18,
    height: 1,
  );
  static const TextStyle timestamp = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 12,
    height: 1,
  );
  static const TextStyle listItem = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 12,
    height: 1,
  );
}

Widget createCircleButton(
        {double size = 32,
        void Function()? cb,
        Widget? child,
        double borderWidth = 2}) =>
    GestureDetector(
      onTap: cb,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: borderWidth,
            color: Colors.white,
          ),
        ),
        child: child,
      ),
    );

Widget line = Container(
  height: 2,
  width: 160,
  color: Colors.white,
  margin: const EdgeInsets.only(top: 2.0, bottom: 4.0),
);

class PlayerPage extends StatefulWidget {
  final Size size;
  final bool isDebug;
  const PlayerPage({
    super.key,
    required this.size,
    required this.isDebug,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.isDebug ? widget.size.height - 30 : widget.size.height,
      decoration: const BoxDecoration(
          // color: Color.fromARGB(121, 238, 3, 81),
          ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Consumer<GlobalModalState>(
          builder: (context, state, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform(
                transform: Matrix4.identity()..translate(-7.0, -10.0, 0.0),
                child: createCircleButton(
                    size: 56,
                    borderWidth: 4,
                    child: const Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                      size: 44,
                    ),
                    cb: () {
                      context.go("/");
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 32),
                child: Column(
                  // Make artist/album title align from left side
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentlyPlaying!.album.artist_name.toUpperCase(),
                      style: Styles.albumArtist,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                    Text(
                      state.currentlyPlaying!.album.album_name.toUpperCase(),
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
                  child: IntrinsicWidth(
                    child: Column(
                      // Make song title align from left side
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SquareTile(
                          size: 160.0,
                          background:
                              state.currentlyPlaying!.album.album_image!,
                        ),
                        line,
                        const Row(
                          // Space between the timestamps
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "0:02",
                              style: Styles.timestamp,
                            ),
                            Text(
                              "-2:34",
                              style: Styles.timestamp,
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            state.currentlyPlaying!.song.name,
                            style: Styles.songTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 40,
                          ),
                          child: FutureBuilder<List<SongModel>>(
                              future: state.currentlyPlaying?.album.getSongs(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<SongModel>> snapshot) {
                                final doneLoading = snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data != null &&
                                    snapshot.data!.isNotEmpty;
                                // Check if over one so that the .length > 3 doesnt break single song albums
                                if (doneLoading && snapshot.data!.length > 1) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: snapshot.data!
                                        .map((e) => Text(
                                              e.name,
                                              style: Styles.listItem,
                                            ))
                                        .toList()
                                        .slice(
                                            1,
                                            snapshot.data!.length > 3
                                                ? 4
                                                : snapshot.data!.length - 1),
                                  );
                                }

                                return const SizedBox.shrink();
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createCircleButton(
                      child: const Icon(
                        Icons.shuffle_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    createCircleButton(
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    createCircleButton(
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
