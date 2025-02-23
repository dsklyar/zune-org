library player_page;

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/pages/overlays_page/index.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/route_utils.dart';

part "page.dart";
part "font_styles.dart";
part "current_track_tile.dart";
part "track_actions_controls.dart";
part "go_back_button.dart";

final console = DebugPrint().register(DebugComponent.controlsPage);
