// ignore_for_file: non_constant_identifier_names

part of database;

class Initializer {
  static Future<void> populateDatabase() async {
    if (await Initializer.isAlreadyInitialized()) {
      console.log("Skipping table population.");
      return;
    }

    final files = Metadata().files;
    Database db = await ZuneDatabase.instance.database;

    // Cache prev generated models;
    final artistMap = <String, ArtistModel>{};
    final albumMap = <String, AlbumModel>{};

    try {
      await db.transaction(
        (txn) async {
          for (var file in files) {
            // Skip tracks with empty or null names
            if (file.title == null || file.title == "") continue;

            // Generate artist
            ArtistModel artist;
            final artist_name = file.artist ?? ArtistModel.defaultArtist;
            if (artistMap.containsKey(artist_name)) {
              artist = artistMap[artist_name]!;
            } else {
              artist = await ArtistModel.create(
                ArtistModel(
                  artist_name: artist_name,
                ),
                txn: txn,
              );
              artistMap.putIfAbsent(artist_name, () => artist);
            }

            // Generate album
            AlbumModel album;
            final album_name = file.album ?? AlbumModel.defaultAlbum;
            if (albumMap.containsKey(album_name)) {
              album = albumMap[album_name]!;
            } else {
              album = await AlbumModel.create(
                AlbumModel(
                  album_name: file.album ?? AlbumModel.defaultAlbum,
                  artist_id: artist.artist_id,
                ),
                txn: txn,
              );
              albumMap.putIfAbsent(album_name, () => album);
            }

            await TrackModel.create(
              TrackModel(
                album_id: album.album_id,
                artist_id: artist.artist_id,
                track_duration: file.duration?.inSeconds ?? 0,
                track_name: file.title!,
                path_to_filename: file.file.path,
              ),
              txn: txn,
            );

            for (var image in file.pictures) {
              await TrackImageModel.create(
                TrackImageModel(
                  album_id: album.album_id,
                  artist_id: artist.artist_id,
                  image_type: image.pictureType.index,
                  image_blob: image.bytes,
                ),
                txn: txn,
              );
            }
          }
        },
      );

      console.log("Tables Created, Done working DB", customTags: ["DATABASE"]);
    } catch (e, st) {
      console.error("Database initialization failed: $e, $st");
    }
  }

  static Future<bool> isAlreadyInitialized() async {
    Database db = await ZuneDatabase.instance.database;

    var queryResult = await db.rawQuery('''
        SELECT COUNT(*) FROM ${TrackModel.tableName};
    ''');

    int count = queryResult.first["COUNT(*)"] as int;

    return count > 0;
  }
}
