library global_state;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/enums/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "global_state.dart";
part "rust_messages.dart";

final console = DebugPrint().register(DebugComponent.globalState);
