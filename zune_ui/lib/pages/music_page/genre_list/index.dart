library genre_list_widget;

import 'dart:collection';

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/widgets/common/index.dart';
import 'package:zune_ui/providers/global_state/index.dart';
import 'package:zune_ui/widgets/over_scroll_wrapper/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "genre_list.dart";
part "genre_list_tile.dart";
part "genre_albums_row.dart";
part "font_styles.dart";

final console = parent.console;
