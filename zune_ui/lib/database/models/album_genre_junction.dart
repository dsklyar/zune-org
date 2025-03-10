part of database;

class AlbumGenreJunctionColumns extends BaseModelColumns {
  const AlbumGenreJunctionColumns();
  String get album_id => "album_id";
  String get genre_id => "genre_id";
  @override
  List<String> get values => [
        album_id,
        genre_id,
      ];
}

class AlbumGenreJunction {
  static const String tableName = "AlbumGenres";
  static const AlbumGenreJunctionColumns columns = AlbumGenreJunctionColumns();

  final int album_id;
  final int genre_id;

  AlbumGenreJunction({
    required this.album_id,
    required this.genre_id,
  });

  AlbumGenreJunction.fromJson(Map<String, Object?> json)
      : album_id = json[columns.album_id] as int,
        genre_id = json[columns.genre_id] as int;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.album_id}"	INTEGER NOT NULL,
            "${columns.genre_id}"	INTEGER NOT NULL,
            PRIMARY KEY("${columns.album_id}", "${columns.genre_id}"),
            FOREIGN KEY("${columns.album_id}") REFERENCES "${AlbumModel.tableName}"("${AlbumModel.columns.album_id}"),
            FOREIGN KEY("${columns.genre_id}") REFERENCES "${GenreModel.tableName}"("${GenreModel.columns.genre_id}")
          );
      ''');
  }

  static Future<AlbumGenreJunction> create(
    AlbumGenreJunction toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    await operator.insert(AlbumGenreJunction.tableName, toCreate.toJson());

    return toCreate;
  }

  Map<String, Object?> toJson() => {
        columns.album_id: album_id,
        columns.genre_id: genre_id,
      };

  AlbumGenreJunction copy({
    int? album_id,
    int? genre_id,
  }) =>
      AlbumGenreJunction(
        album_id: album_id ?? this.album_id,
        genre_id: genre_id ?? this.genre_id,
      );

  static Future<List<AlbumGenreJunction>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      AlbumGenreJunction.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
    );

    return result
        .map(
          (json) => AlbumGenreJunction.fromJson(json),
        )
        .toList();
  }
}
