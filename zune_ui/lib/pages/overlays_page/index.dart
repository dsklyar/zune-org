library overlays_page;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:zune_ui/pages/search_index_page/index.dart';
import 'package:zune_ui/pages/controls_page/index.dart';
import 'package:zune_ui/pages/splash_page/index.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "page.dart";
part "wrapper.dart";

const initialSize = Size(272, 480);
const isDebug = kDebugMode;

final console = DebugPrint().register(DebugComponent.overlaysPage);
