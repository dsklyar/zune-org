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
  late final AnimationController _overlayAnimationController;

  late final OverlayPortalController _overlayController;

  @override
  void initState() {
    super.initState();
    _overlayController = OverlayPortalController();

    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
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
    if (_overlayAnimationController.isAnimating) {
      _overlayAnimationController.reset();
    } else {
      _overlayAnimationController.forward().then((_) {
        _overlayController.hide();
        _overlayAnimationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// NOTE: Very curious thing here:
    ///       If I change this to SizedBox and remove decoration,
    ///       the windows system will play notification sound when clicking on background of said box
    return Container(
      width: widget.size.width,
      height: widget.isDebug ? widget.size.height - 30 : widget.size.height,
      decoration: const BoxDecoration(color: Colors.translucent),
      child: Stack(
        children: [
          OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (context) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(
                    parent: _overlayAnimationController,
                    curve: Curves.easeInExpo,
                  ),
                ),
                child: ControlsPage(
                  closeOverlayHandler: closeOverlay,
                ),
              );
            },
          ),
          Consumer<GlobalModalState>(
            builder: (context, state, child) {
              if (state.currentlyPlaying == null) {
                return const SizedBox.shrink();
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
                      child: Column(
                        // Make song title align from left side
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CurrentTrackTile(
                            showOverlay: showOverlay,
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
                  const TrackActionsControls(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
