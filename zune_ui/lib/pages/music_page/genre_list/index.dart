library genre_list_widget;

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/pages/music_page/common/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "genre_list.dart";
part "genre_list_tile.dart";

final console = parent.console;
