part of database;

class ZuneDatabase {
  static final ZuneDatabase instance = ZuneDatabase._internal();

  static Database? _database;

  ZuneDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    await Initializer.populateDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    console.log("Initiating Database", customTags: ["DATABASE"]);

    // https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/using_ffi_instead_of_sqflite.md
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    /// NOTE: Creating the directory if it doesn't exist
    ///       One can't simply create folders in OS, so using this for now:
    ///       -> https://pub.dev/packages/path_provider
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/zune.db';

    console.log("Database $path", customTags: ["DATABASE"]);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        final batch = db.batch();
        _createDatabaseV1(batch);
        await batch.commit();
      },
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> _createDatabaseV1(Batch batch) async {
    console.log(
      "Creating tables in _createDatabaseV1",
      customTags: [
        "DATABASE",
      ],
    );

    batch.execute(ArtistModel.createModelScript());
    batch.execute(GenreModel.createModelScript());
    batch.execute(AlbumModel.createModelScript());
    batch.execute(AlbumGenreJunction.createModelScript());
    batch.execute(TrackModel.createModelScript());
    batch.execute(TrackImageModel.createModelScript());
    batch.execute(AlbumSummary.createModelScript());
    batch.execute(PlaylistModel.createModelScript());
    batch.execute(PlaylistTrackJunction.createModelScript());
  }
}
