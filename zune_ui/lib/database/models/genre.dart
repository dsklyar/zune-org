// ignore_for_file: non_constant_identifier_names
part of database;

class GenreModelColumns extends BaseModelColumns {
  const GenreModelColumns();
  String get genre_id => "genre_id";
  String get genre_name => "genre_name";
  @override
  List<String> get values => [
        genre_id,
        genre_name,
      ];
}

class GenreModel implements PlayableItem {
  static const String tableName = "Genres";
  static const String defaultGenre = "unknown genre";
  static const GenreModelColumns columns = GenreModelColumns();

  final int genre_id;
  final String genre_name;

  GenreModel({
    this.genre_id = -1,
    this.genre_name = GenreModel.defaultGenre,
  });

  GenreModel.fromJson(Map<String, Object?> json)
      : genre_id = json[columns.genre_id] as int,
        genre_name = json[columns.genre_name] as String;

  static String createModelScript() {
    return ('''
          CREATE TABLE "$tableName" (
            "${columns.genre_id}"	INTEGER NOT NULL UNIQUE,
            "${columns.genre_name}"	TEXT DEFAULT '$defaultGenre' UNIQUE,
            PRIMARY KEY("${columns.genre_id}" AUTOINCREMENT)
          );
      ''');
  }

  static Future<GenreModel> create(
    GenreModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final queryResult = await operator.query(
      GenreModel.tableName,
      columns: columns.values,
      where: '${columns.genre_name} = ?',
      whereArgs: [toCreate.genre_name],
    );

    final foundEntry = queryResult.isEmpty
        ? null
        : queryResult.firstWhereOrNull((item) =>
            GenreModel.fromJson(item).genre_name == toCreate.genre_name);

    int genre_id = foundEntry != null
        ? GenreModel.fromJson(foundEntry).genre_id
        : await operator.insert(
            GenreModel.tableName,
            toCreate.toJson(),
          );

    return toCreate.copy(genre_id: genre_id);
  }

  Map<String, Object?> toJson() => {
        columns.genre_id: genre_id == -1 ? null : genre_id,
        columns.genre_name: genre_name,
      };

  GenreModel copy({
    int? genre_id,
    String? genre_name,
  }) =>
      GenreModel(
        genre_id: genre_id ?? this.genre_id,
        genre_name: genre_name ?? this.genre_name,
      );

  static Future<GenreModel> read(int id) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final maps = await db.query(
      GenreModel.tableName,
      columns: columns.values,
      where: '${columns.genre_id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GenreModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<GenreModel>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      GenreModel.tableName,
      where: where != null ? columns.toSqlClause(where) : null,
      orderBy: '${GenreModel.tableName}.${GenreModel.columns.genre_id} DESC',
    );

    return result
        .map(
          (json) => GenreModel.fromJson(json),
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
