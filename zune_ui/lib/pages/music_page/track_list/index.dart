library track_list_widget;

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/pages/music_page/common/index.dart';
import 'package:zune_ui/pages/overlays_page/index.dart';
import 'package:zune_ui/pages/search_index_page/index.dart'
    show SearchIndexConfig;
import 'package:zune_ui/widgets/common/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "track_list.dart";
part "track_list_tile.dart";
part "constants.dart";

final console = parent.console;
