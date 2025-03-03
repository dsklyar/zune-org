// ignore_for_file: non_constant_identifier_names, constant_identifier_names

part of database;

class CollectorConfiguration {
  static const int DEFAULT_COUNT = 20;
  final int max_pinned_items_count;
  final int max_new_items_count;
  final int max_history_items_count;

  const CollectorConfiguration({
    this.max_pinned_items_count = CollectorConfiguration.DEFAULT_COUNT,
    this.max_new_items_count = CollectorConfiguration.DEFAULT_COUNT,
    this.max_history_items_count = CollectorConfiguration.DEFAULT_COUNT,
  });
}

class Collector {
  final CollectorConfiguration collectorConfiguration;

  final Map<int, TrackSummary> _tracksMap = {};
  final Map<int, AlbumSummary> _albumMap = {};
  final Map<int, ArtistSummary> _artistMap = {};
  final Map<int, GenreSummary> _genreMap = {};
  final Map<int, PlaylistSummary> _playlistMap = {};

  List<TrackSummary> get allTracks => _tracksMap.values.toList();
  List<AlbumSummary> get allAlbums => _albumMap.values.toList();
  List<ArtistSummary> get allArtists => _artistMap.values.toList();
  List<GenreSummary> get allGenres => _genreMap.values.toList();
  List<PlaylistSummary> get allPlayLists => _playlistMap.values.toList();

  final List<InteractiveItem> _newlyAddedItems = [];
  final List<InteractiveItem> _pinnedItems = [];
  // TODO add LRU here
  final List<InteractiveItem> _recentlyPlayedItems = [];

  List<InteractiveItem> get newlyAddedItems => _newlyAddedItems;
  List<InteractiveItem> get pinnedItems => _pinnedItems;
  List<InteractiveItem> get recentlyPlayedItems => _recentlyPlayedItems;

  Collector({
    this.collectorConfiguration = const CollectorConfiguration(),
  });

  Future<void> initializeCollector() async {
    await Initializer.populateDatabase();

    assignTrack(TrackSummary track) => _tracksMap[track.track_id] = track;
    (await TrackSummary.readAll()).forEach(assignTrack);

    assignAlbum(AlbumSummary album) => _albumMap[album.album_id] = album;
    (await AlbumSummary.readAll()).forEach(assignAlbum);

    assignArtist(ArtistSummary artist) => _artistMap[artist.artist_id] = artist;
    (await ArtistSummary.readAll()).forEach(assignArtist);

    assignGenre(GenreSummary genre) => _genreMap[genre.genre_id] = genre;
    (await GenreSummary.readAll()).forEach(assignGenre);

    assignPlaylist(PlaylistSummary playlist) =>
        _playlistMap[playlist.playlist_id] = playlist;
    (await PlaylistSummary.readAll()).forEach(assignPlaylist);

    pushToNewlyAddedItems(AlbumSummary album) => _newlyAddedItems.add(album);
    (await _getNewAddedAlbums(
      limit: collectorConfiguration.max_new_items_count,
    ))
        .forEach(pushToNewlyAddedItems);
  }

  Future<void> updateRecentlyPlayedItems(InteractiveItem item) async {
    if (_recentlyPlayedItems.length >=
        collectorConfiguration.max_new_items_count) {
      _recentlyPlayedItems.removeLast();
    } else if (_recentlyPlayedItems.contains(item)) {
      _recentlyPlayedItems.remove(item);
    }
    _recentlyPlayedItems.insert(0, item);
  }

  /// Private Methods

  Future<List<AlbumSummary>> _getNewAddedAlbums({int limit = 8}) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.query(
      AlbumSummary.tableName,
      orderBy:
          '${AlbumSummary.tableName}.${AlbumSummary.columns.added_at} DESC',
      limit: limit,
    );

    return result
        .map(
          (json) => AlbumSummary.fromJson(json),
        )
        .toList();
  }
}
