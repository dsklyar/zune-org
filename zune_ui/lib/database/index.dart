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

    return await db.execute('''
          ${SongModel.createModelScript()}
          ${AlbumModel.createModelScript()}
      ''');
  }
}

class SongModel {
  static String tableName = "Songs";
  static List<String> columns = [
    "song_id",
    "album_name",
    "artist_name",
    "duration",
    "name",
    "path_to_filename",
    "image_blob"
  ];
  final int? song_id;
  final String? album_name;
  final String? artist_name;
  final int? duration;
  final String name;
  final String path_to_filename;
  final Uint8List? image_blob;

  SongModel(this.song_id, this.album_name, this.artist_name, this.duration,
      this.name, this.path_to_filename, this.image_blob);

  static String createModelScript() {
    return ('''
          CREATE TABLE "Songs" (
            "song_id"	INTEGER NOT NULL UNIQUE,
            "album_name"	TEXT DEFAULT 'unknown album',
            "artist_name"	TEXT DEFAULT 'unknown artist',
            "duration"  INTEGER DEFAULT 0,
            "name"	TEXT NOT NULL,
            "path_to_filename"	TEXT NOT NULL,
            "image_blob"	BLOB,
            PRIMARY KEY("song_id" AUTOINCREMENT)
          );
      ''');
  }

  static Future<SongModel> create(SongModel song) async {
    final ZuneDatabase zune = ZuneDatabase.instance;
    final db = await zune.database;
    final song_id = await db.insert(SongModel.tableName, song.toJson());
    return song.copy(song_id: song_id);
  }

  Map<String, Object?> toJson() => {
        "song_id": song_id,
        "album_name": album_name,
        "artist_name": artist_name,
        "duration": duration,
        "name": name,
        "path_to_filename": path_to_filename,
        "image_blob": image_blob,
      };

  SongModel copy({
    int? song_id,
    String? album_name,
    String? artist_name,
    int? duration,
    String? name,
    String? path_to_filename,
    Uint8List? image_blob,
  }) =>
      SongModel(
        song_id ?? this.song_id,
        album_name ?? this.album_name,
        artist_name ?? this.artist_name,
        duration ?? this.duration,
        name ?? this.name,
        path_to_filename ?? this.path_to_filename,
        image_blob ?? this.image_blob,
      );

  static SongModel fromJson(Map<String, Object?> json) => SongModel(
        json[columns[0]] as int?,
        json[columns[1]] as String?,
        json[columns[2]] as String?,
        json[columns[3]] as int?,
        json[columns[4]] as String,
        json[columns[5]] as String,
        json[columns[6]] as Uint8List?,
      );

  Future<SongModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      SongModel.tableName,
      columns: SongModel.columns,
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
    "song_count",
    "total_duration",
    "album_image",
    "song_ids"
  ];
  final String album_name;
  final String artist_name;
  final int song_count;
  final int total_duration;
  Uint8List? album_image;
  List<int> song_ids = [];

  AlbumModel(this.album_name, this.artist_name, this.song_count,
      this.total_duration, this.album_image, this.song_ids);

  static String createModelScript() {
    return ('''
          CREATE VIEW AlbumSummary AS
          SELECT 
              album_name,
              artist_name,
              COUNT(song_id) AS song_count,
              SUM(duration) AS total_duration,
              MAX(image_blob) AS album_image,
              GROUP_CONCAT(song_id) AS song_ids
          FROM 
              Songs
          GROUP BY 
              album_name, artist_name;
      ''');
  }

  Map<String, Object?> toJson() => {
        "album_name": album_name,
        "artist_name": artist_name,
        "song_count": song_count,
        "total_duration": total_duration,
        "album_image": album_image,
        "song_ids": song_ids.join(",")
      };

  AlbumModel copy({
    String? album_name,
    String? artist_name,
    int? song_count,
    int? total_duration,
    Uint8List? album_image,
    List<int>? song_ids,
  }) =>
      AlbumModel(
        album_name ?? this.album_name,
        artist_name ?? this.artist_name,
        song_count ?? this.song_count,
        total_duration ?? this.total_duration,
        album_image ?? this.album_image,
        song_ids ?? this.song_ids,
      );

  static AlbumModel fromJson(Map<String, Object?> json) => AlbumModel(
        json[columns[0]] as String,
        json[columns[1]] as String,
        json[columns[2]] as int,
        json[columns[3]] as int,
        json[columns[4]] as Uint8List,
        (json[columns[5]] as String).split(",").map(int.parse).toList(),
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

  Future<List<SongModel>> getSongs() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.rawQuery('''
      SELECT
          *
      FROM
          Songs
      WHERE
          song_id IN (${song_ids.join(", ")});
    ''');

    if (maps.isNotEmpty) {
      return maps.map((json) => SongModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Album ${album_name}_did not find ids with ${song_ids.join(", ")}');
    }
  }

  static Future<List<AlbumModel>> readAll() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(AlbumModel.tableName,
        orderBy: '${AlbumModel.columns[0]} DESC');

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
        SELECT COUNT(*) FROM ${SongModel.tableName};
    ''');
    var count = queryResult.first["COUNT(*)"] as int;
    console.log("Should fill tables: Is count > 0?  ${count > 0}",
        customTags: ["DATABASE"]);

    if (count > 0) return;

    final files = Metadata("music_dir").files;
    for (var file in files) {
      final Uint8List? imageBytes = file.pictures
          .firstWhereOrNull(
              (element) => element.pictureType == PictureType.coverFront)
          ?.bytes;

      SongModel.create(
        SongModel(
          null,
          file.album,
          file.artist,
          file.duration?.inSeconds,
          file.title ?? "EMPTY",
          file.file.path,
          imageBytes,
        ),
      );
    }

    console.log("Tables Created, Done working DB", customTags: ["DATABASE"]);
  }
}
