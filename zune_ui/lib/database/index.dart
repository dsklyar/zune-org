// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zune_ui/database/metadata.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

final console = DebugPrint().register(DebugComponent.database);

class ZuneDatabase {
  static final ZuneDatabase instance = ZuneDatabase._internal();

  static Database? _database;

  ZuneDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    // if debug please seed my databussy
    await Seed.seed();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    console.log("Initiating Database", customTags: ["DATABASE"]);

    // https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/using_ffi_instead_of_sqflite.md
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/zune.db';
    console.log("Database $path", customTags: ["DATABASE"]);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> _createDatabase(Database db, int version) async {
    /// TODO: Reference images in a separate table and load them on getAll
    console.log("Creating tables in _createDatabase", customTags: ["DATABASE"]);

    /// TODO: It seems that on MacOS I need to split these scripts into separate calls.
    ///       Otherwise, the AlbumSummary view is not created.
    await db.execute(TrackModel.createModelScript());
    await db.execute(TrackImageModel.createModelScript());
    return await db.execute(AlbumModel.createModelScript());
  }
}

class TrackImageModel {
  static String tableName = "TrackImages";
  final int? image_id;
  final String? album_name;
  final String? artist_name;
  final int? image_type;
  final Uint8List? image_blob;

  TrackImageModel(
    this.image_id,
    this.album_name,
    this.artist_name,
    this.image_type,
    this.image_blob,
  );

  static String createModelScript() {
    return ('''
        CREATE TABLE "TrackImages" (
            "image_id" INTEGER NOT NULL UNIQUE,
            "artist_name" TEXT NOT NULL,
            "album_name" TEXT NOT NULL,
            "image_type" INTEGER DEFAULT 0,
            "image_blob" BLOB,
            PRIMARY KEY("image_id" AUTOINCREMENT),
            FOREIGN KEY("artist_name", "album_name") REFERENCES "Tracks"("artist_name", "album_name") ON DELETE CASCADE
            UNIQUE ("artist_name", "album_name", "image_type")
        );
      ''');
  }

  static Future<TrackImageModel> create(TrackImageModel trackImage) async {
    final ZuneDatabase zune = ZuneDatabase.instance;
    final db = await zune.database;
    final image_id =
        await db.insert(TrackImageModel.tableName, trackImage.toJson());
    return trackImage.copy(image_id: image_id);
  }

  Map<String, Object?> toJson() => {
        "image_id": image_id,
        "artist_name": artist_name,
        "album_name": album_name,
        "image_type": image_type,
        "image_blob": image_blob,
      };

  TrackImageModel copy({
    int? image_id,
    String? artist_name,
    String? album_name,
    int? image_type,
    Uint8List? image_blob,
  }) =>
      TrackImageModel(
        image_id ?? this.image_id,
        artist_name ?? this.artist_name,
        album_name ?? this.album_name,
        image_type ?? this.image_type,
        image_blob ?? this.image_blob,
      );
}

class TrackModel {
  static String tableName = "Tracks";
  static List<String> columns = [
    "track_id",
    "album_name",
    "artist_name",
    "duration",
    "name",
    "path_to_filename",
  ];
  final int? track_id;
  final String? album_name;
  final String? artist_name;
  final int? duration;
  final String name;
  final String path_to_filename;

  TrackModel(
    this.track_id,
    this.album_name,
    this.artist_name,
    this.duration,
    this.name,
    this.path_to_filename,
  );

  static String createModelScript() {
    return ('''
          CREATE TABLE "Tracks" (
            "track_id"	INTEGER NOT NULL UNIQUE,
            "album_name"	TEXT DEFAULT 'unknown album',
            "artist_name"	TEXT DEFAULT 'unknown artist',
            "duration"  INTEGER DEFAULT 0,
            "name"	TEXT NOT NULL,
            "path_to_filename"	TEXT NOT NULL,
            PRIMARY KEY("track_id" AUTOINCREMENT)
          );
      ''');
  }

  static Future<TrackModel> create(TrackModel track) async {
    final ZuneDatabase zune = ZuneDatabase.instance;
    final db = await zune.database;
    final track_id = await db.insert(TrackModel.tableName, track.toJson());
    return track.copy(track_id: track_id);
  }

  Map<String, Object?> toJson() => {
        "track_id": track_id,
        "album_name": album_name,
        "artist_name": artist_name,
        "duration": duration,
        "name": name,
        "path_to_filename": path_to_filename,
      };

  TrackModel copy({
    int? track_id,
    String? album_name,
    String? artist_name,
    int? duration,
    String? name,
    String? path_to_filename,
  }) =>
      TrackModel(
        track_id ?? this.track_id,
        album_name ?? this.album_name,
        artist_name ?? this.artist_name,
        duration ?? this.duration,
        name ?? this.name,
        path_to_filename ?? this.path_to_filename,
      );

  static TrackModel fromJson(Map<String, Object?> json) => TrackModel(
        json[columns[0]] as int?,
        json[columns[1]] as String?,
        json[columns[2]] as String?,
        json[columns[3]] as int?,
        json[columns[4]] as String,
        json[columns[5]] as String,
      );

  Future<TrackModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      TrackModel.tableName,
      columns: TrackModel.columns,
      where: '${columns[0]} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }
}

class AlbumModel {
  static String tableName = "AlbumSummary";
  static List<String> columns = [
    "album_name",
    "artist_name",
    "track_count",
    "total_duration",
    "album_cover",
    "album_illustration",
    "track_ids"
  ];
  final String album_name;
  final String artist_name;
  final int track_count;
  final int total_duration;
  Uint8List? album_cover;
  Uint8List? album_illustration;
  List<int> track_ids = [];

  AlbumModel(
    this.album_name,
    this.artist_name,
    this.track_count,
    this.total_duration,
    this.album_cover,
    this.album_illustration,
    this.track_ids,
  );

  static String createModelScript() {
    return ('''
          CREATE VIEW "AlbumSummary" AS
          SELECT 
              tracks.album_name AS album_name,
              tracks.artist_name AS artist_name,
              COUNT(tracks.track_id) AS track_count,
              SUM(tracks.duration) AS total_duration,
              ai1.image_blob AS album_cover,
              ai2.image_blob AS album_illustration,
              GROUP_CONCAT(tracks.track_id) AS track_ids
          FROM 
              Tracks tracks
          LEFT JOIN
            TrackImages ai1
          ON
            tracks.album_name = ai1.album_name AND
            tracks.artist_name = ai1.artist_name AND
            ai1.image_type = 3
          LEFT JOIN
            TrackImages ai2
          ON
            tracks.album_name = ai2.album_name AND
            tracks.artist_name = ai2.artist_name AND
            ai2.image_type = 18
          GROUP BY 
              tracks.album_name, tracks.artist_name;
      ''');
  }

  Map<String, Object?> toJson() => {
        "album_name": album_name,
        "artist_name": artist_name,
        "track_count": track_count,
        "total_duration": total_duration,
        "album_cover": album_cover,
        "album_illustration": album_illustration,
        "track_ids": track_ids.join(",")
      };

  AlbumModel copy({
    String? album_name,
    String? artist_name,
    int? track_count,
    int? total_duration,
    Uint8List? album_cover,
    Uint8List? album_illustration,
    List<int>? track_ids,
  }) =>
      AlbumModel(
        album_name ?? this.album_name,
        artist_name ?? this.artist_name,
        track_count ?? this.track_count,
        total_duration ?? this.total_duration,
        album_cover ?? this.album_cover,
        album_illustration ?? this.album_illustration,
        track_ids ?? this.track_ids,
      );

  static AlbumModel fromJson(Map<String, Object?> json) => AlbumModel(
        json[columns[0]] as String,
        json[columns[1]] as String,
        json[columns[2]] as int,
        json[columns[3]] as int,
        json[columns[4]] as Uint8List?,
        json[columns[5]] as Uint8List?,
        (json[columns[6]] as String).split(",").map(int.parse).toList(),
      );

  static Future<AlbumModel> read(String album_name, String artist_name) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      AlbumModel.tableName,
      columns: AlbumModel.columns,
      where: '${columns[0]} = ? AND ${columns[1]} = ?',
      whereArgs: [album_name, artist_name],
    );

    if (maps.isNotEmpty) {
      return fromJson(maps.first);
    } else {
      throw Exception('Album with $album_name and $artist_name found');
    }
  }

  Future<List<TrackModel>> getTracks() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.rawQuery('''
      SELECT
          *
      FROM
          Tracks
      WHERE
          track_id IN (${track_ids.join(", ")});
    ''');

    if (maps.isNotEmpty) {
      return maps.map((json) => TrackModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Album ${album_name}_did not find ids with ${track_ids.join(", ")}');
    }
  }

  static Future<List<AlbumModel>> readAll() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(AlbumModel.tableName,
        orderBy: '${AlbumModel.tableName}.${AlbumModel.columns[0]} DESC');

    return result
        .map(
          (json) => AlbumModel.fromJson(json),
        )
        .toList();
  }
}

class ArtistModel {
  static String tableName = "Artists";
  static List<String> columns = ["artist_id", "name"];
  final int? artist_id;
  final String name;

  ArtistModel(this.artist_id, this.name);

  Future<ArtistModel> create(ArtistModel artist) async {
    final ZuneDatabase zune = ZuneDatabase.instance;
    final db = await zune.database;
    final artist_id = await db.insert(ArtistModel.tableName, artist.toJson());
    return artist.copy(artist_id: artist_id);
  }

  Map<String, Object?> toJson() => {
        "artist_id": artist_id,
        "name": name,
      };

  ArtistModel copy({
    int? artist_id,
    String? name,
  }) =>
      ArtistModel(
        artist_id ?? this.artist_id,
        name ?? this.name,
      );

  ArtistModel fromJson(Map<String, Object?> json) => ArtistModel(
        json[columns[0]] as int?,
        json[columns[1]] as String,
      );

  Future<ArtistModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      ArtistModel.tableName,
      columns: ArtistModel.columns,
      where: '${columns[0]} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }
}

class Seed {
  static Future<void> seed() async {
    var db = await ZuneDatabase.instance.database;
    var queryResult = await db.rawQuery('''
        SELECT COUNT(*) FROM ${TrackModel.tableName};
    ''');
    var count = queryResult.first["COUNT(*)"] as int;
    console.log("Should fill tables: Is count > 0?  ${count > 0}",
        customTags: ["DATABASE"]);

    if (count > 0) return;

    final files = Metadata("music_dir").files;
    for (var file in files) {
      // final Uint8List? imageBytes = file.pictures
      //     .firstWhereOrNull(
      //         (element) => element.pictureType == PictureType.coverFront)
      //     ?.bytes;

      final track = await TrackModel.create(
        TrackModel(
          null,
          file.album,
          file.artist,
          file.duration?.inSeconds,
          file.title ?? "EMPTY",
          file.file.path,
        ),
      );
      if (file.pictures.length > 1) {
        console.log("IMAGES found ${file.pictures.length} for ${file.album}");
      }
      for (var image in file.pictures) {
        TrackImageModel.create(
          TrackImageModel(
            null,
            track.album_name,
            track.artist_name,
            image.pictureType.index,
            image.bytes,
          ),
        );
      }
    }

    console.log("Tables Created, Done working DB", customTags: ["DATABASE"]);
  }
}
