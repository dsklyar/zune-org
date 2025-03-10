part of database;

class PlaylistTrackJunctionColumns extends BaseModelColumns {
  const PlaylistTrackJunctionColumns();
  String get playlist_id => "playlist_id";
  String get track_id => "track_id";
  String get track_order => "track_order";
  @override
  List<String> get values => [
        playlist_id,
        track_id,
        track_order,
      ];
}

class PlaylistTrackJunction {
  static const String tableName = "PlaylistTracks";
  static const PlaylistTrackJunctionColumns columns =
      PlaylistTrackJunctionColumns();

  final int playlist_id;
  final int track_id;
  final int order;

  PlaylistTrackJunction({
    required this.playlist_id,
    required this.track_id,
    required this.order,
  });

  PlaylistTrackJunction.fromJson(Map<String, Object?> json)
      : playlist_id = json[columns.playlist_id] as int,
        track_id = json[columns.track_id] as int,
        order = json[columns.track_order] as int;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.playlist_id}"	INTEGER NOT NULL,
            "${columns.track_id}"	INTEGER NOT NULL,
            "${columns.track_order}" INTEGER NOT NULL,
            PRIMARY KEY("${columns.playlist_id}", "${columns.track_id}"),
            FOREIGN KEY("${columns.playlist_id}") REFERENCES "${PlaylistModel.tableName}"("${PlaylistModel.columns.playlist_id}"),
            FOREIGN KEY("${columns.track_id}") REFERENCES "${TrackModel.tableName}"("${TrackModel.columns.track_id}")
          );
      ''');
  }

  static Future<PlaylistTrackJunction> create(
    PlaylistTrackJunction toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    await operator.insert(PlaylistTrackJunction.tableName, toCreate.toJson());

    return toCreate;
  }

  Map<String, Object?> toJson() => {
        columns.playlist_id: playlist_id,
        columns.track_id: track_id,
        columns.track_order: order,
      };

  PlaylistTrackJunction copy({
    int? playlist_id,
    int? track_id,
    int? order,
  }) =>
      PlaylistTrackJunction(
        playlist_id: playlist_id ?? this.playlist_id,
        track_id: track_id ?? this.track_id,
        order: track_id ?? this.track_id,
      );

  static Future<List<PlaylistTrackJunction>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      PlaylistTrackJunction.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
    );

    return result
        .map(
          (json) => PlaylistTrackJunction.fromJson(json),
        )
        .toList();
  }
}
