library splash_page;

import 'dart:async';

import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';
import 'package:zune_ui/widgets/custom/time_utils.dart';

part "page.dart";
part "clock.dart";
part "font_styles.dart";

final console = DebugPrint().register(DebugComponent.splashPage);
