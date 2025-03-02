// ignore_for_file: non_constant_identifier_names

part of database;

class TrackSummaryColumns extends TrackModelColumns {
  const TrackSummaryColumns();
  String get album_name => "album_name";
  String get artist_name => "artist_name";
  @override
  List<String> get values => [
        album_name,
        artist_name,
        ...super.values,
      ];
}

class TrackSummary extends TrackModel {
  static const TrackSummaryColumns columns = TrackSummaryColumns();
  final String artist_name;
  final String album_name;

  TrackSummary({
    required this.artist_name,
    required this.album_name,
    required super.track_name,
    required super.path_to_filename,
  });

  static Future<List<TrackSummary>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.rawQuery('''
      SELECT
        tracks.*,
        artists.${ArtistModel.columns.artist_name} as ${ArtistModel.columns.artist_name},
        albums.${AlbumModel.columns.album_name} as ${AlbumModel.columns.album_name}
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
      ${where != null ? "WHERE ${columns.toSqlClause(where)};" : ''}
    ''');

    return result
        .map(
          (json) => TrackSummary.fromJson(json),
        )
        .toList();
  }

  TrackSummary.fromJson(Map<String, Object?> json)
      : album_name = json[columns.album_name] as String,
        artist_name = json[columns.artist_name] as String,
        super.fromJson(json);
}
