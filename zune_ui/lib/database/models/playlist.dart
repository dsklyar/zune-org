part of database;

class PlaylistModelColumns extends BaseModelColumns {
  const PlaylistModelColumns();
  String get playlist_id => "playlist_id";
  String get playlist_name => "playlist_name";
  @override
  List<String> get values => [
        playlist_id,
        playlist_name,
      ];
}

class PlaylistModel implements PlayableItem {
  static const String tableName = "Playlists";
  static const PlaylistModelColumns columns = PlaylistModelColumns();

  final int playlist_id;
  final String playlist_name;

  PlaylistModel({
    this.playlist_id = -1,
    required this.playlist_name,
  });

  PlaylistModel.fromJson(Map<String, Object?> json)
      : playlist_id = json[columns.playlist_id] as int,
        playlist_name = json[columns.playlist_name] as String;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.playlist_id}" INTEGER NOT NULL UNIQUE,
            "${columns.playlist_name}" TEXT NOT NULL UNIQUE,
            PRIMARY KEY("${columns.playlist_id}" AUTOINCREMENT)
          );
      ''');
  }

  static Future<PlaylistModel> create(
    PlaylistModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final queryResult = await operator.query(
      PlaylistModel.tableName,
      columns: columns.values,
      where: '${columns.playlist_name} = ?',
      whereArgs: [toCreate.playlist_name],
    );

    final foundEntry = queryResult.isEmpty
        ? null
        : queryResult.firstWhereOrNull((item) =>
            PlaylistModel.fromJson(item).playlist_name ==
            toCreate.playlist_name);

    int playlist_id = foundEntry != null
        ? PlaylistModel.fromJson(foundEntry).playlist_id
        : await operator.insert(
            PlaylistModel.tableName,
            toCreate.toJson(),
          );

    return toCreate.copy(playlist_id: playlist_id);
  }

  Map<String, Object?> toJson() => {
        columns.playlist_id: playlist_id == -1 ? null : playlist_id,
        columns.playlist_name: playlist_name,
      };

  PlaylistModel copy({
    int? playlist_id,
    String? playlist_name,
  }) =>
      PlaylistModel(
        playlist_id: playlist_id ?? this.playlist_id,
        playlist_name: playlist_name ?? this.playlist_name,
      );

  static Future<PlaylistModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      PlaylistModel.tableName,
      columns: columns.values,
      where: '${columns.playlist_id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PlaylistModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<PlaylistModel>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      PlaylistModel.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
      orderBy:
          '${PlaylistModel.tableName}.${PlaylistModel.columns.playlist_id} DESC',
    );

    return result
        .map(
          (json) => PlaylistModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $playlist_name playlist to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $playlist_name playlist to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console
        .log("Pretend to add $playlist_name playlist to Now Playing Playlist");
  }
}
