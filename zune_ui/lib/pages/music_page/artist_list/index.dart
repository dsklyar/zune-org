library artist_list_widget;

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/pages/overlays_page/index.dart';
import 'package:zune_ui/pages/music_page/common/index.dart';

/// NOTE: Scoping imports behind parent, so that console log & utils is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "artist_list.dart";
part "artist_list_tile.dart";

final console = parent.console;
