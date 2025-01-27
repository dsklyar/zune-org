library player_page;

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/pages/controls_page/page.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "font_styles.dart";
part "current_track_tile.dart";
part "track_actions_controls.dart";
part "return_button.dart";

final console = DebugPrint().register(DebugComponent.controlsPage);

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
  late final OverlayPortalController _overlayController;

  double _offset = 0.0; // Track the offset of AlbumTile

  @override
  void initState() {
    super.initState();
    _overlayController = OverlayPortalController();

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

  void showOverlay() {
    _overlayController.show();
  }

  /// Handler responsible for controlling OverlayPortal's closing behavior
  /// 1. If handler needs to be closed without animation, use "fastClose" parameter
  /// 2. If controller is animating the closing effect, reset opacity to 100%
  /// 3. Otherwise, forward animation to 0% opacity, hide the Overlay
  ///    and reset the animation controller for future use
  void closeOverlay({bool? fastClose = false}) {
    if (fastClose == true) {
      _overlayController.hide();
      return;
    }
    if (_controller.isAnimating) {
      _controller.reset();
    } else {
      _controller.forward().then((_) {
        _overlayController.hide();
        _controller.reset();
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      final temp = _offset + details.delta.dx;

      // TODO: fix magical numbers for width
      if (temp < 272 && temp > -272) {
        _offset += details.delta.dx;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final globalState = context.read<GlobalModalState>();

    // TODO: Fix magical numbers
    if (_offset > (272 / 2)) {
      console.log("User swiped right, playing previous song");
      globalState.playNextPrevSong(-1);
    } else if (_offset < -(272 / 2)) {
      console.log("User swiped left, playing next song");
      globalState.playNextPrevSong(1);
    }

    // Reset offset
    setState(() {
      _offset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.isDebug ? widget.size.height - 30 : widget.size.height,
      child: Stack(
        children: [
          OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (context) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.linear,
                  ),
                ),
                child: ControlsPage(
                  closeOverlayHandler: closeOverlay,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Consumer<GlobalModalState>(
              builder: (context, state, child) {
                if (state.currentlyPlaying == null) {
                  return SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReturnButton(),
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
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: _onHorizontalDragEnd,
                          onHorizontalDragCancel: () => setState(() {
                            _offset = 0.0;
                          }),
                          child: Column(
                            // Make song title align from left side
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CurrentTrackTile(
                                showOverlay: showOverlay,
                                offset: _offset,
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
                                                  e.name,
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
                    ),
                    const TrackActionsControls(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
