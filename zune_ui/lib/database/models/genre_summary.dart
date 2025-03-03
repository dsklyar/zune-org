// ignore_for_file: non_constant_identifier_names
part of database;

class GenreSummaryColumns extends GenreModelColumns {
  const GenreSummaryColumns();
  String get album_ids => "album_ids";
  @override
  List<String> get values => [
        album_ids,
        ...super.values,
      ];
}

class GenreSummary extends GenreModel {
  static const GenreSummaryColumns columns = GenreSummaryColumns();

  final List<int> album_ids;

  GenreSummary({
    this.album_ids = const [],
  });

  GenreSummary.fromJson(Map<String, Object?> json)
      : album_ids = (json[columns.album_ids] as String)
            .split(",")
            .map(int.parse)
            .toList(),
        super.fromJson(json);

  static Future<List<GenreSummary>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.rawQuery('''
      SELECT
        genres.*,
        GROUP_CONCAT(albumGenres.${AlbumGenreJunction.columns.album_id}) AS ${GenreSummary.columns.album_ids}
      FROM
        ${GenreModel.tableName} genres
      LEFT JOIN
        ${AlbumGenreJunction.tableName} albumGenres
      ON
        genres.${GenreModel.columns.genre_id} = albumGenres.${AlbumGenreJunction.columns.genre_id}
      ${where != null ? "WHERE ${columns.toSqlClause(where)}" : ''}
      GROUP BY 
        genres.${GenreModel.columns.genre_name};
    ''');

    return result
        .map(
          (json) => GenreSummary.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> addToQuickplay() async {
    console.log("Pretend to add $genre_name genre to Pins");
  }

  @override
  Future<void> removeFromQuickplay() async {
    console.log("Pretend to remove $genre_name genre to Pins");
  }

  @override
  Future<void> addToNowPlaying() async {
    console.log("Pretend to add $genre_name genre to Now Playing Playlist");
  }
}
