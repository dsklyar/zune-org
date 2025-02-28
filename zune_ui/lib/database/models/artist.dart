// ignore_for_file: non_constant_identifier_names
part of database;

class ArtistModelColumns extends BaseModelColumns {
  const ArtistModelColumns();
  String get artist_id => "artist_id";
  String get artist_name => "artist_name";
  @override
  List<String> get values => [
        artist_id,
        artist_name,
      ];
}

class ArtistModel implements PlayableItem {
  static const String tableName = "Artists";
  static const String defaultArtist = "unknown artist";
  static const ArtistModelColumns columns = ArtistModelColumns();

  // DATABASE PROPERTIES
  final int artist_id;
  final String artist_name;

  ArtistModel({
    this.artist_id = -1,
    this.artist_name = ArtistModel.defaultArtist,
  });

  ArtistModel.fromJson(Map<String, Object?> json)
      : artist_id = json[columns.artist_id] as int,
        artist_name = json[columns.artist_name] as String;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.artist_id}"	INTEGER NOT NULL UNIQUE,
            "${columns.artist_name}"	TEXT DEFAULT '$defaultArtist' UNIQUE,
            PRIMARY KEY("${columns.artist_id}" AUTOINCREMENT)
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
      columns: columns.values,
      where: '${columns.artist_name} = ?',
      whereArgs: [toCreate.artist_name],
    );

    final foundEntry = queryResult.isEmpty
        ? null
        : queryResult.firstWhereOrNull((item) =>
            ArtistModel.fromJson(item).artist_name == toCreate.artist_name);

    int artist_id = foundEntry != null
        ? ArtistModel.fromJson(foundEntry).artist_id
        : await operator.insert(
            ArtistModel.tableName,
            toCreate.toJson(),
          );

    final artistModel = toCreate.copy(artist_id: artist_id);
    return artistModel;
  }

  Map<String, Object?> toJson() => {
        columns.artist_id: artist_id == -1 ? null : artist_id,
        columns.artist_name: artist_name,
      };

  ArtistModel copy({
    int? artist_id,
    String? artist_name,
  }) =>
      ArtistModel(
        artist_id: artist_id ?? this.artist_id,
        artist_name: artist_name ?? this.artist_name,
      );

  static Future<ArtistModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      ArtistModel.tableName,
      columns: columns.values,
      where: '${columns.artist_id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ArtistModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<ArtistModel>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      ArtistModel.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
      orderBy: '${ArtistModel.tableName}.${ArtistModel.columns.artist_id} DESC',
    );

    return result
        .map(
          (json) => ArtistModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $artist_name artist to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $artist_name artist to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $artist_name artist to Now Playing Playlist");
  }
}
