library music_page;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:zune_ui/pages/music_page/music_categories/index.dart';
import 'package:zune_ui/pages/music_page/view_selector/index.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/route_utils.dart';

part "page.dart";
part "animation_provider.dart";

final console = DebugPrint().register(DebugComponent.musicPage);
