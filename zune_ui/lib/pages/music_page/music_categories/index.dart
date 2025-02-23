library music_categories_widget;

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:memoized/memoized.dart';
import 'package:provider/provider.dart';
import 'package:zune_ui/enums/index.dart';
import 'package:zune_ui/providers/global_state/global_state.dart';
import 'package:zune_ui/widgets/common/index.dart';

/// NOTE: Scoping imports behind parent, so that console log is exposed from Music Page
import 'package:zune_ui/pages/music_page/index.dart' as parent;

part "music_categories.dart";
part "music_categories_wrapper.dart";
part "font_styles.dart";

final console = parent.console;
