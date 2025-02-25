// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

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

    await Initializer.populateDatabase();
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
      onCreate: (db, version) async {
        final batch = db.batch();
        _createDatabaseV1(batch);
        await batch.commit();
      },
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> _createDatabaseV1(Batch batch) async {
    console.log(
      "Creating tables in _createDatabaseV1",
      customTags: [
        "DATABASE",
      ],
    );

    batch.execute(ArtistModel.createModelScript());
    batch.execute(TrackModel.createModelScript());
    batch.execute(TrackImageModel.createModelScript());
    batch.execute(AlbumModel.createModelScript());
  }
}

class TrackImageModel {
  static String tableName = "TrackImages";
  static List<String> columns = [
    "image_id",
    "album_name",
    "artist_id",
    "image_type",
    "image_blob",
  ];
  final int? image_id;
  final String? album_name;
  final int? artist_id;
  final int? image_type;
  final Uint8List? image_blob;

  TrackImageModel(
    this.image_id,
    this.album_name,
    this.artist_id,
    this.image_type,
    this.image_blob,
  );

  static String createModelScript() {
    return ('''
        CREATE TABLE "TrackImages" (
            "image_id" INTEGER NOT NULL UNIQUE,
            "artist_id" INTEGER NOT NULL,
            "album_name" TEXT NOT NULL,
            "image_type" INTEGER DEFAULT 0,
            "image_blob" BLOB,
            PRIMARY KEY("image_id" AUTOINCREMENT),
            FOREIGN KEY("artist_id", "album_name") REFERENCES "Tracks"("artist_id", "album_name") ON DELETE CASCADE
            UNIQUE ("artist_id", "album_name", "image_type")
        );
      ''');
  }

  static TrackImageModel fromJson(Map<String, Object?> json) => TrackImageModel(
        json[columns[0]] as int?,
        json[columns[1]] as String?,
        json[columns[2]] as int?,
        json[columns[3]] as int?,
        json[columns[3]] as Uint8List?,
      );

  static Future<TrackImageModel> create(
    TrackImageModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final image_id = await operator.insert(
      TrackImageModel.tableName,
      toCreate.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return toCreate.copy(image_id: image_id);
  }

  Map<String, Object?> toJson() => {
        "image_id": image_id,
        "artist_id": artist_id,
        "album_name": album_name,
        "image_type": image_type,
        "image_blob": image_blob,
      };

  TrackImageModel copy({
    int? image_id,
    int? artist_id,
    String? album_name,
    int? image_type,
    Uint8List? image_blob,
  }) =>
      TrackImageModel(
        image_id ?? this.image_id,
        album_name ?? this.album_name,
        artist_id ?? this.artist_id,
        image_type ?? this.image_type,
        image_blob ?? this.image_blob,
      );
}

class TrackModel extends PlayableItem {
  static String tableName = "Tracks";
  static List<String> columns = [
    "track_id",
    "album_name",
    "artist_id",
    "duration",
    "name",
    "path_to_filename",
  ];
  final int? track_id;
  final String? album_name;
  final int? artist_id;
  final int? duration;
  final String name;
  final String path_to_filename;

  /// NON-TABLE Properties
  String artist_name = ArtistModel.defaultArtist;

  TrackModel(
    this.track_id,
    this.album_name,
    this.artist_id,
    this.duration,
    this.name,
    this.path_to_filename,
  );

  static String createModelScript() {
    return ('''
          CREATE TABLE "Tracks" (
            "track_id"	INTEGER NOT NULL UNIQUE,
            "album_name"	TEXT DEFAULT 'unknown album',
            "artist_id" INTEGER NOT NULL,
            "duration"  INTEGER DEFAULT 0,
            "name"	TEXT NOT NULL,
            "path_to_filename"	TEXT NOT NULL,
            PRIMARY KEY("track_id" AUTOINCREMENT)
            FOREIGN KEY("artist_id") REFERENCES "Artists"("artist_id")
          );
      ''');
  }

  static Future<TrackModel> create(
    TrackModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;
    final track_id =
        await operator.insert(TrackModel.tableName, toCreate.toJson());
    return toCreate.copy(track_id: track_id);
  }

  Map<String, Object?> toJson() => {
        "track_id": track_id,
        "album_name": album_name,
        "artist_id": artist_id,
        "duration": duration,
        "name": name,
        "path_to_filename": path_to_filename,
      };

  TrackModel copy({
    int? track_id,
    String? album_name,
    int? artist_id,
    int? duration,
    String? name,
    String? path_to_filename,
  }) =>
      TrackModel(
        track_id ?? this.track_id,
        album_name ?? this.album_name,
        artist_id ?? this.artist_id,
        duration ?? this.duration,
        name ?? this.name,
        path_to_filename ?? this.path_to_filename,
      );

  static TrackModel fromJson(Map<String, Object?> json) => TrackModel(
        json[columns[0]] as int?,
        json[columns[1]] as String?,
        json[columns[2]] as int?,
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

  @override
  Future<void> addToQuickplay() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to add $name song to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to remove $name song to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to add $name song to Now Playing Playlist");
  }
}

class AlbumModel extends PlayableItem {
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

  /// NON-TABLE Properties
  List<TrackModel> tracks = [];

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
          CREATE VIEW "${AlbumModel.tableName}" AS
          SELECT 
              tracks.album_name AS album_name,
              artists.artist_name AS artist_name,
              COUNT(tracks.track_id) AS track_count,
              SUM(tracks.duration) AS total_duration,
              ai1.image_blob AS album_cover,
              ai2.image_blob AS album_illustration,
              GROUP_CONCAT(tracks.track_id) AS track_ids
          FROM 
            ${TrackModel.tableName} tracks
          LEFT JOIN
            ${ArtistModel.tableName} artists
          ON
            tracks.artist_id = artists.artist_id
          LEFT JOIN
            ${TrackImageModel.tableName} ai1
          ON
            tracks.album_name = ai1.album_name AND
            tracks.artist_id = ai1.artist_id AND
            ai1.image_type = 3
          LEFT JOIN
            ${TrackImageModel.tableName} ai2
          ON
            tracks.album_name = ai2.album_name AND
            tracks.artist_id = ai2.artist_id AND
            ai2.image_type = 18
          GROUP BY 
              tracks.album_name, artists.artist_name;
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
          ${TrackModel.tableName}
      WHERE
          track_id IN (${track_ids.join(", ")});
    ''');

    if (maps.isNotEmpty) {
      tracks = maps.map((json) {
        final track = TrackModel.fromJson(json);
        track.artist_name = artist_name;
        return track;
      }).toList();
      return tracks;
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

  @override
  Future<void> addToQuickplay() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to add $album_name song to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to remove $album_name song to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    Future.delayed(const Duration(seconds: 1));
    console.log("Pretend to add $album_name song to Now Playing Playlist");
  }
}

class ArtistModel extends PlayableItem {
  static String tableName = "Artists";
  static List<String> columns = ["artist_id", "artist_name"];
  static String defaultArtist = "unknown artist";
  final int? artist_id;
  final String artist_name;

  ArtistModel(this.artist_id, this.artist_name);

  static String createModelScript() {
    return ('''
          CREATE TABLE "Artists" (
            "artist_id"	INTEGER NOT NULL UNIQUE,
            "artist_name"	TEXT DEFAULT '$defaultArtist' UNIQUE,
            PRIMARY KEY("artist_id" AUTOINCREMENT)
          );
      ''');
  }

  static Future<ArtistModel> create(
    ArtistModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final queryResult = await operator.query(
      ArtistModel.tableName,
      columns: ArtistModel.columns,
      where: '${columns[1]} = ?',
      whereArgs: [toCreate.artist_name],
    );

    final foundEntry = queryResult.firstWhereOrNull((item) =>
        ArtistModel.fromJson(item).artist_name == toCreate.artist_name);

    int artist_id = foundEntry != null
        ? ArtistModel.fromJson(foundEntry).artist_id!
        : await operator.insert(
            ArtistModel.tableName,
            toCreate.toJson(),
          );

    final artistModel = toCreate.copy(artist_id: artist_id);
    return artistModel;
  }

  Map<String, Object?> toJson() => {
        "artist_id": artist_id,
        "artist_name": artist_name,
      };

  ArtistModel copy({
    int? artist_id,
    String? artist_name,
  }) =>
      ArtistModel(
        artist_id ?? this.artist_id,
        artist_name ?? this.artist_name,
      );

  static ArtistModel fromJson(Map<String, Object?> json) => ArtistModel(
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

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $artist_name song to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $artist_name song to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $artist_name song to Now Playing Playlist");
  }
}

class Initializer {
  static Future<void> populateDatabase() async {
    if (await Initializer.isAlreadyInitialized()) {
      console.log("Skipping table population.");
      return;
    }

    final files = Metadata().files;
    Database db = await ZuneDatabase.instance.database;

    try {
      await db.transaction(
        (txn) async {
          for (var file in files) {
            final artist = await ArtistModel.create(
              ArtistModel(null, file.artist ?? ArtistModel.defaultArtist),
              txn: txn,
            );

            final track = await TrackModel.create(
              TrackModel(
                null,
                file.album,
                artist.artist_id,
                file.duration?.inSeconds,
                file.title ?? "EMPTY",
                file.file.path,
              ),
              txn: txn,
            );

            for (var image in file.pictures) {
              await TrackImageModel.create(
                TrackImageModel(
                  null,
                  track.album_name,
                  artist.artist_id,
                  image.pictureType.index,
                  image.bytes,
                ),
                txn: txn,
              );
            }
          }
        },
      );

      console.log("Tables Created, Done working DB", customTags: ["DATABASE"]);
    } catch (e, st) {
      console.error("Database initialization failed: $e, $st");
    }
  }

  static Future<bool> isAlreadyInitialized() async {
    Database db = await ZuneDatabase.instance.database;

    var queryResult = await db.rawQuery('''
        SELECT COUNT(*) FROM ${TrackModel.tableName};
    ''');

    int count = queryResult.first["COUNT(*)"] as int;

    return count > 0;
  }
}

abstract class InteractiveItem {
  Future<void> addToQuickplay();
  Future<void> removeFromQuickplay();
}

abstract class PlayableItem extends InteractiveItem {
  Future<void> addToNowPlaying();
}
