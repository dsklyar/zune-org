// ignore_for_file: non_constant_identifier_names

part of database;

class AlbumModelColumns {
  const AlbumModelColumns();
  String get album_id => "album_id";
  String get album_name => "album_name";
  String get artist_id => "artist_id";
  List<String> get values => [
        album_id,
        album_name,
        artist_id,
      ];
}

class AlbumModel implements PlayableItem {
  static String tableName = "AlbumModel";
  static const String defaultAlbum = "unknown album";
  static const AlbumModelColumns columns = AlbumModelColumns();

  final int album_id;
  final String album_name;
  final int? artist_id;

  AlbumModel({
    this.album_id = -1,
    this.album_name = "",
    this.artist_id,
  });

  AlbumModel.fromJson(Map<String, Object?> json)
      : album_id = json[columns.album_id] as int,
        album_name = json[columns.album_name] as String,
        artist_id = json[columns.artist_id] as int;

  static String createModelScript() {
    /// NOTE: Adding composite unique constraint on album_name and artist_id to ensure
    ///       that each artist does not have duplicate albums but allow multiple artists
    ///       to have albums with the same name.
    return ('''
           CREATE TABLE "$tableName" (
            "${columns.album_id}"	INTEGER NOT NULL UNIQUE,
            "${columns.album_name}"	TEXT NOT NULL,
            "${columns.artist_id}" INTEGER NOT NULL,
            PRIMARY KEY("${columns.album_id}" AUTOINCREMENT)
            FOREIGN KEY("${columns.artist_id}") REFERENCES "${ArtistModel.tableName}"("${ArtistModel.columns.artist_id}")
            UNIQUE("${columns.album_name}", "${columns.artist_id}")
          );
      ''');
  }

  static Future<AlbumModel> create(
    AlbumModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final queryResult = await operator.query(
      AlbumModel.tableName,
      columns: columns.values,

      /// NOTE: Querying for both artist and album name to make sure
      ///       the correct album.
      where: '${columns.album_name} = ? AND ${columns.artist_id} = ?',
      whereArgs: [toCreate.album_name, toCreate.artist_id],
    );

    final foundEntry = queryResult.isEmpty
        ? null
        : queryResult.firstWhereOrNull((item) {
            final foundAlbum = AlbumModel.fromJson(item);
            return foundAlbum.album_name == toCreate.album_name &&
                foundAlbum.artist_id == toCreate.artist_id;
          });

    int album_id = foundEntry != null
        ? AlbumModel.fromJson(foundEntry).album_id
        : await operator.insert(
            AlbumModel.tableName,
            toCreate.toJson(),
          );

    final albumModel = toCreate.copy(album_id: album_id);
    return albumModel;
  }

  Map<String, Object?> toJson() => {
        columns.album_id: album_id == -1 ? null : album_id,
        columns.album_name: album_name,
        columns.artist_id: artist_id,
      };

  AlbumModel copy({
    int? album_id,
    String? album_name,
    int? artist_id,
  }) =>
      AlbumModel(
        album_id: album_id ?? this.album_id,
        album_name: album_name ?? this.album_name,
        artist_id: artist_id ?? this.artist_id,
      );

  static Future<AlbumModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      AlbumModel.tableName,
      columns: columns.values,
      where: '${columns.album_id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AlbumModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<AlbumModel>> readAll() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      AlbumModel.tableName,
      orderBy: '${AlbumModel.tableName}.${AlbumModel.columns.album_id} DESC',
    );

    return result
        .map(
          (json) => AlbumModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $album_name album to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $album_name album to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $album_name album to Now Playing Playlist");
  }
}
