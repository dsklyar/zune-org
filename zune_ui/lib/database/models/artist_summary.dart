// ignore_for_file: non_constant_identifier_names
part of database;

class ArtistSummaryColumns extends ArtistModelColumns {
  const ArtistSummaryColumns();
  String get album_ids => "album_ids";
  @override
  List<String> get values => [
        album_ids,
        ...super.values,
      ];
}

class ArtistSummary extends ArtistModel {
  static const ArtistSummaryColumns columns = ArtistSummaryColumns();

  final List<int> album_ids;

  ArtistSummary({this.album_ids = const []});

  ArtistSummary.fromJson(Map<String, Object?> json)
      : album_ids = (json[columns.album_ids] as String)
            .split(",")
            .map(int.parse)
            .toList(),
        super.fromJson(json);

  static Future<List<ArtistSummary>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.rawQuery('''
      SELECT
        artists.*,
        GROUP_CONCAT(albums.${AlbumModel.columns.album_id}) AS ${ArtistSummary.columns.album_ids}
      FROM
        ${ArtistModel.tableName} artists
      LEFT JOIN
        ${AlbumModel.tableName} albums
      ON
        artists.${ArtistModel.columns.artist_id} = albums.${AlbumModel.columns.artist_id}
      ${where != null ? "WHERE ${columns.toSqlClause(where)};" : ''}
      GROUP BY 
        artists.${ArtistModel.columns.artist_name};
    ''');

    return result
        .map(
          (json) => ArtistSummary.fromJson(json),
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
