part of database;

class TrackModelColumns extends BaseModelColumns {
  const TrackModelColumns() : super();
  String get track_id => "track_id";
  String get album_id => "album_id";
  String get artist_id => "artist_id";
  String get track_duration => "track_duration";
  String get track_name => "track_name";
  String get path_to_filename => "path_to_filename";
  @override
  List<String> get values => [
        track_id,
        album_id,
        artist_id,
        track_duration,
        track_name,
        path_to_filename,
      ];
}

class TrackModel implements PlayableItem {
  static String tableName = "Tracks";
  static const TrackModelColumns columns = TrackModelColumns();

  final int track_id;
  final int? album_id;
  final int? artist_id;
  final int track_duration;
  final String track_name;
  final String path_to_filename;

  TrackModel({
    this.track_id = -1,
    this.album_id,
    this.artist_id,
    this.track_duration = 0,
    required this.track_name,
    required this.path_to_filename,
  });

  TrackModel.fromJson(Map<String, Object?> json)
      : track_id = json[columns.track_id] as int,
        album_id = json[columns.album_id] as int?,
        artist_id = json[columns.artist_id] as int?,
        track_duration = json[columns.track_duration] as int,
        track_name = json[columns.track_name] as String,
        path_to_filename = json[columns.path_to_filename] as String;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.track_id}"	INTEGER NOT NULL UNIQUE,
            "${columns.album_id}"	 INTEGER NOT NULL,
            "${columns.artist_id}" INTEGER NOT NULL,
            "${columns.track_duration}"  INTEGER DEFAULT 0,
            "${columns.track_name}"	TEXT NOT NULL,
            "${columns.path_to_filename}"	TEXT NOT NULL,
            PRIMARY KEY("${columns.track_id}" AUTOINCREMENT)
            FOREIGN KEY("${columns.artist_id}") REFERENCES "${ArtistModel.tableName}"("${ArtistModel.columns.artist_id}")
            FOREIGN KEY("${columns.album_id}") REFERENCES "${AlbumModel.tableName}"("${AlbumModel.columns.album_id}")
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
        columns.track_id: track_id == -1 ? null : track_id,
        columns.album_id: album_id,
        columns.artist_id: artist_id,
        columns.track_duration: track_duration,
        columns.track_name: track_name,
        columns.path_to_filename: path_to_filename,
      };

  TrackModel copy({
    int? track_id,
    int? album_id,
    int? artist_id,
    int? track_duration,
    String? track_name,
    String? path_to_filename,
  }) =>
      TrackModel(
        track_id: track_id ?? this.track_id,
        album_id: album_id ?? this.album_id,
        artist_id: artist_id ?? this.artist_id,
        track_duration: track_duration ?? this.track_duration,
        track_name: track_name ?? this.track_name,
        path_to_filename: path_to_filename ?? this.path_to_filename,
      );

  static Future<TrackModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      TrackModel.tableName,
      columns: TrackModel.columns.values,
      where: '${columns.track_id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TrackModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<TrackModel>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      TrackModel.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
      orderBy: '${TrackModel.tableName}.${TrackModel.columns.track_id} DESC',
    );

    return result
        .map(
          (json) => TrackModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $track_name song to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $track_name song to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $track_name song to Now Playing Playlist");
  }
}
