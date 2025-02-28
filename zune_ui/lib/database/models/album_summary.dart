// ignore_for_file: non_constant_identifier_names

part of database;

class AlbumSummaryColumns {
  const AlbumSummaryColumns();
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

class AlbumSummary implements PlayableItem {
  static String tableName = "AlbumSummary";
  static const AlbumSummaryColumns columns = AlbumSummaryColumns();

  final String album_name;
  final String artist_name;
  final int track_count;
  final int total_duration;
  Uint8List? album_cover;
  Uint8List? album_illustration;
  List<int> track_ids = [];

  AlbumSummary({
    this.album_name = "",
    this.artist_name = "",
    this.track_count = 0,
    this.total_duration = 0,
    this.album_cover,
    this.album_illustration,
    this.track_ids = const [],
  });

  AlbumSummary.fromJson(Map<String, Object?> json)
      : album_name = json[columns.album_name] as String,
        artist_name = json[columns.artist_name] as String,
        track_count = json[columns.track_count] as int,
        total_duration = json[columns.total_duration] as int,
        album_cover = json[columns.album_cover] as Uint8List?,
        album_illustration = json[columns.album_illustration] as Uint8List?,
        track_ids = (json[columns.track_ids] as String)
            .split(",")
            .map(int.parse)
            .toList();

  static String createModelScript() {
    return ('''
          CREATE VIEW "${AlbumSummary.tableName}" AS
          SELECT 
              albums.${AlbumModel.columns.album_name} AS ${AlbumSummary.columns.album_name},
              artists.artist_name AS artist_name,
              COUNT(tracks.${TrackModel.columns.track_id}) AS ${AlbumSummary.columns.track_count},
              SUM(tracks.${TrackModel.columns.track_duration}) AS ${AlbumSummary.columns.total_duration},
              ai1.${TrackImageModel.columns.image_blob} AS ${AlbumSummary.columns.album_cover},
              ai2.${TrackImageModel.columns.image_blob} AS ${AlbumSummary.columns.album_illustration},
              GROUP_CONCAT(tracks.${TrackModel.columns.track_id}) AS ${AlbumSummary.columns.track_ids}
          FROM 
            ${TrackModel.tableName} tracks
          LEFT JOIN
            ${ArtistModel.tableName} artists
          ON
            tracks.${TrackModel.columns.artist_id} = artists.${ArtistModel.columns.artist_id}
          LEFT JOIN
            ${AlbumModel.tableName} albums
          ON
            tracks.${TrackModel.columns.album_id} = albums.${AlbumModel.columns.album_id}
          LEFT JOIN
            ${TrackImageModel.tableName} ai1
          ON
            tracks.${TrackModel.columns.album_id} = ai1.${TrackImageModel.columns.album_id} AND
            tracks.${TrackModel.columns.artist_id} = ai1.${TrackImageModel.columns.artist_id} AND
            ai1.${TrackImageModel.columns.image_type} = 3
          LEFT JOIN
            ${TrackImageModel.tableName} ai2
          ON
            tracks.${TrackModel.columns.album_id} = ai2.${TrackImageModel.columns.album_id} AND
            tracks.${TrackModel.columns.artist_id} = ai2.${TrackImageModel.columns.artist_id} AND
            ai2.${TrackImageModel.columns.image_type} = 18
          GROUP BY 
              albums.${AlbumModel.columns.album_name}, artists.${ArtistModel.columns.artist_name};
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

  AlbumSummary copy({
    String? album_name,
    String? artist_name,
    int? track_count,
    int? total_duration,
    Uint8List? album_cover,
    Uint8List? album_illustration,
    List<int>? track_ids,
  }) =>
      AlbumSummary(
        album_name: album_name ?? this.album_name,
        artist_name: artist_name ?? this.artist_name,
        track_count: track_count ?? this.track_count,
        total_duration: total_duration ?? this.total_duration,
        album_cover: album_cover ?? this.album_cover,
        album_illustration: album_illustration ?? this.album_illustration,
        track_ids: track_ids ?? this.track_ids,
      );

  static Future<AlbumSummary> read(
    String album_name,
    String artist_name,
  ) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      AlbumSummary.tableName,
      columns: AlbumSummary.columns.values,
      where: '${columns.album_name} = ? AND ${columns.artist_name} = ?',
      whereArgs: [album_name, artist_name],
    );

    if (maps.isNotEmpty) {
      return AlbumSummary.fromJson(maps.first);
    } else {
      throw Exception('Album with $album_name and $artist_name found');
    }
  }

  Future<List<TrackSummary>> getTracks() async {
    final tracks = await TrackSummary.readAll(
      where: {
        TrackSummary.columns.track_id: WhereClauseValue(
          op: Operator.inOp,
          value: track_ids,
        )
      },
    );

    if (tracks.isNotEmpty) {
      return tracks;
    } else {
      throw Exception(
          'Album ${album_name}_did not find ids with ${track_ids.join(", ")}');
    }
  }

  static Future<List<AlbumSummary>> readAll() async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(AlbumSummary.tableName,
        orderBy:
            '${AlbumSummary.tableName}.${AlbumSummary.columns.album_name} DESC');

    return result
        .map(
          (json) => AlbumSummary.fromJson(json),
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
