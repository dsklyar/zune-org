library view_selector_widget;

import 'package:flutter/widgets.dart';
import 'package:zune_ui/enums/index.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/pages/music_page/album_grid/index.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "view_selector.dart";
part "empty_category.dart";
part "view_mount_transition.dart";
part "view_slide_transition.dart";

final console = parent.console;
