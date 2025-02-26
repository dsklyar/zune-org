// ignore_for_file: non_constant_identifier_names
library database;

import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zune_ui/database/metadata.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "models/shared.dart";
part "models/artist.dart";
part "models/track_image.dart";
part "models/track.dart";
part "models/album_summary.dart";
part "database.dart";
part "initializer.dart";

final console = DebugPrint().register(DebugComponent.database);
