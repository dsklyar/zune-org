library player_page;

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/pages/overlays_page/page.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/route_utils.dart';

part "font_styles.dart";
part "current_track_tile.dart";
part "track_actions_controls.dart";
part "return_button.dart";

final console = DebugPrint().register(DebugComponent.controlsPage);

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// NOTE: This provider exposes all of the overlays in the app
    final overlaysProvider = OverlaysProvider.of(context);

    /// NOTE: Very curious thing here:
    ///       If I change this to SizedBox and remove decoration,
    ///       the windows system will play notification sound when clicking on background of said box
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      decoration: const BoxDecoration(color: Colors.translucent),
      child: Consumer<GlobalModalState>(
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
                  child: Column(
                    // Make song title align from left side
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrentTrackTile(
                        showOverlay: () =>
                            overlaysProvider!.showOverlay(OverlayType.controls),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
