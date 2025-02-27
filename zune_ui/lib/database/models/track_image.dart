// ignore_for_file: non_constant_identifier_names
part of database;

class TrackImageModelColumns {
  const TrackImageModelColumns();
  String get image_id => "image_id";
  String get album_id => "album_id";
  String get artist_id => "artist_id";
  String get image_type => "image_type";
  String get image_blob => "image_blob";
  List<String> get values => [
        image_id,
        album_id,
        artist_id,
        image_type,
        image_blob,
      ];
}

class TrackImageModel {
  static String tableName = "TrackImages";
  static const TrackImageModelColumns columns = TrackImageModelColumns();

  final int image_id;
  final int? album_id;
  final int? artist_id;
  final int image_type;
  final Uint8List image_blob;

  TrackImageModel({
    this.image_id = -1,
    this.album_id,
    this.artist_id,
    required this.image_type,
    required this.image_blob,
  });

  static String createModelScript() {
    return ('''
        CREATE TABLE "$tableName" (
            "${columns.image_id}" INTEGER NOT NULL UNIQUE,
            "${columns.artist_id}" INTEGER NOT NULL,
            "${columns.album_id}" INTEGER NOT NULL,
            "${columns.image_type}" INTEGER DEFAULT 0,
            "${columns.image_blob}" BLOB NOT NULL,
            PRIMARY KEY("${columns.image_id}" AUTOINCREMENT),
            FOREIGN KEY("${columns.image_id}", "${columns.album_id}")
              REFERENCES "${TrackModel.tableName}"("${TrackModel.columns.artist_id}", "${TrackModel.columns.album_id}") ON DELETE CASCADE
            UNIQUE ("${columns.artist_id}", "${columns.album_id}", "${columns.image_type}")
        );
      ''');
  }

  static TrackImageModel fromJson(Map<String, Object?> json) => TrackImageModel(
        image_id: json[columns.image_id] as int,
        album_id: json[columns.album_id] as int?,
        artist_id: json[columns.artist_id] as int?,
        image_type: json[columns.image_type] as int,
        image_blob: json[columns.image_blob] as Uint8List,
      );

  static Future<TrackImageModel> create(
    TrackImageModel toCreate, {
    Transaction? txn,
  }) async {
    DatabaseExecutor operator = txn ?? await ZuneDatabase.instance.database;

    final image_id = await operator.insert(
      TrackImageModel.tableName,
      toCreate.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return toCreate.copy(image_id: image_id);
  }

  Map<String, Object?> toJson() => {
        columns.image_id: image_id == -1 ? null : image_id,
        columns.artist_id: artist_id,
        columns.album_id: album_id,
        columns.image_type: image_type,
        columns.image_blob: image_blob,
      };

  TrackImageModel copy({
    int? image_id,
    int? artist_id,
    int? album_id,
    int? image_type,
    Uint8List? image_blob,
  }) =>
      TrackImageModel(
        image_id: image_id ?? this.image_id,
        album_id: album_id ?? this.album_id,
        artist_id: artist_id ?? this.artist_id,
        image_type: image_type ?? this.image_type,
        image_blob: image_blob ?? this.image_blob,
      );
}
