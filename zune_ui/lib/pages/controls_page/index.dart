library controls_page;

import 'dart:math';

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/time_utils.dart';
import 'package:zune_ui/widgets/fade_animation_wrapper/index.dart';

part "page.dart";
part "volume_label.dart";
part "font_styles.dart";
part "backdrop.dart";
part "currently_playing_label.dart";
part "volume_control.dart";
part "playback_control.dart";
part "play_pause_control.dart";
part "track_label_animation.dart";

final console = DebugPrint().register(DebugComponent.controlsPage);
