library album_grid_widget;

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/pages/overlays_page/index.dart';
import 'package:zune_ui/providers/global_state/index.dart';
import 'package:zune_ui/widgets/over_scroll_wrapper/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "album_grid.dart";
part "album_grid_tile.dart";
part "font_styles.dart";

final console = parent.console;
