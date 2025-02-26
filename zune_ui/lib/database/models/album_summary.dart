// ignore_for_file: non_constant_identifier_names

part of database;

class AlbumModelColumns {
  const AlbumModelColumns();
  String get album_name => "album_name";
  String get artist_name => "artist_name";
  String get track_count => "track_count";
  String get total_duration => "total_duration";
  String get album_cover => "album_cover";
  String get album_illustration => "album_illustration";
  String get track_ids => "track_ids";
  List<String> get values => [
        album_name,
        artist_name,
        track_count,
        total_duration,
        album_cover,
        album_illustration,
        track_ids,
      ];
}

class AlbumModel extends PlayableItem {
  static String tableName = "AlbumSummary";
  static const AlbumModelColumns columns = AlbumModelColumns();

  final String album_name;
  final String artist_name;
  final int track_count;
  final int total_duration;
  Uint8List? album_cover;
  Uint8List? album_illustration;
  List<int> track_ids = [];

  /// NON-TABLE Properties
  List<TrackModel> tracks = [];

  AlbumModel({
    this.album_name = "",
    this.artist_name = "",
    this.track_count = 0,
    this.total_duration = 0,
    this.album_cover,
    this.album_illustration,
    this.track_ids = const [],
  });

  static String createModelScript() {
    return ('''
          CREATE VIEW "${AlbumModel.tableName}" AS
          SELECT 
              tracks.${TrackModel.columns.album_name} AS album_name,
              artists.artist_name AS artist_name,
              COUNT(tracks.${TrackModel.columns.track_id}) AS track_count,
              SUM(tracks.${TrackModel.columns.track_duration}) AS total_duration,
              ai1.${TrackImageModel.columns.image_blob} AS album_cover,
              ai2.${TrackImageModel.columns.image_blob} AS album_illustration,
              GROUP_CONCAT(tracks.${TrackModel.columns.track_id}) AS track_ids
          FROM 
            ${TrackModel.tableName} tracks
          LEFT JOIN
            ${ArtistModel.tableName} artists
          ON
            tracks.${TrackModel.columns.artist_id} = artists.${ArtistModel.columns.artist_id}
          LEFT JOIN
            ${TrackImageModel.tableName} ai1
          ON
            tracks.${TrackModel.columns.album_name} = ai1.${TrackImageModel.columns.album_name} AND
            tracks.${TrackModel.columns.artist_id} = ai1.${TrackImageModel.columns.artist_id} AND
            ai1.${TrackImageModel.columns.image_type} = 3
          LEFT JOIN
            ${TrackImageModel.tableName} ai2
          ON
            tracks.${TrackModel.columns.album_name} = ai2.${TrackImageModel.columns.album_name} AND
            tracks.${TrackModel.columns.artist_id} = ai2.${TrackImageModel.columns.artist_id} AND
            ai2.${TrackImageModel.columns.image_type} = 18
          GROUP BY 
              tracks.${TrackModel.columns.album_name}, artists.${ArtistModel.columns.artist_name};
      ''');
  }

  Map<String, Object?> toJson() => {
        columns.album_name: album_name,
        columns.artist_name: artist_name,
        columns.track_count: track_count,
        columns.total_duration: total_duration,
        columns.album_cover: album_cover,
        columns.album_illustration: album_illustration,
        columns.track_ids: track_ids.join(",")
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
        album_name: album_name ?? this.album_name,
        artist_name: artist_name ?? this.artist_name,
        track_count: track_count ?? this.track_count,
        total_duration: total_duration ?? this.total_duration,
        album_cover: album_cover ?? this.album_cover,
        album_illustration: album_illustration ?? this.album_illustration,
        track_ids: track_ids ?? this.track_ids,
      );

  static AlbumModel fromJson(Map<String, Object?> json) => AlbumModel(
        album_name: json[columns.album_name] as String,
        artist_name: json[columns.artist_name] as String,
        track_count: json[columns.track_count] as int,
        total_duration: json[columns.total_duration] as int,
        album_cover: json[columns.album_cover] as Uint8List?,
        album_illustration: json[columns.album_illustration] as Uint8List?,
        track_ids: (json[columns.track_ids] as String)
            .split(",")
            .map(int.parse)
            .toList(),
      );

  static Future<AlbumModel> read(String album_name, String artist_name) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      AlbumModel.tableName,
      columns: AlbumModel.columns.values,
      where: '${columns.album_name} = ? AND ${columns.artist_name} = ?',
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
        orderBy:
            '${AlbumModel.tableName}.${AlbumModel.columns.album_name} DESC');

    return result
        .map(
          (json) => AlbumModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $album_name song to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $album_name song to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $album_name song to Now Playing Playlist");
  }
}
