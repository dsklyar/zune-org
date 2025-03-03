// ignore_for_file: non_constant_identifier_names
library database;

import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

part "models/shared.dart";
part "models/genre.dart";
part "models/genre_summary.dart";
part "models/album_genre_junction.dart";
part "models/artist.dart";
part "models/artist_summary.dart";
part "models/track.dart";
part "models/track_image.dart";
part "models/track_summary.dart";
part "models/album.dart";
part "models/album_summary.dart";
part "database.dart";
part "initializer.dart";
part "metadata.dart";
part "collector.dart";

final console = DebugPrint().register(DebugComponent.database);
