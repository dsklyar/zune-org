part of database;

class Collector {
  final Map<String, TrackModel> _tracksMap = {};
  final Map<String, AlbumModel> _albumMap = {};
  final Map<String, ArtistModel> _artistMap = {};

  Collector();

  Future initialize() async {
    await Initializer.populateDatabase();

    final albums = await AlbumModel.readAll();
    _albumMap.addEntries(
      albums.map(
        (album) => MapEntry(
          "${album.album_name}\\${album.artist_name}",
          album,
        ),
      ),
    );

    final tracks = await TrackModel.readAll();
    _tracksMap.addEntries(
      tracks.map(
        (track) => MapEntry(
          "${track.track_id}",
          track,
        ),
      ),
    );

    final artists = await ArtistModel.readAll();
    _artistMap.addEntries(
      artists.map(
        (artist) => MapEntry(
          "${artist.artist_id}",
          artist,
        ),
      ),
    );
  }
}
