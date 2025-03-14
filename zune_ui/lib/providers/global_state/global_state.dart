part of global_state;

typedef CurrentlyPlaying = ({AlbumSummary album, TrackSummary song})?;

class GlobalModalState extends ChangeNotifier {
  final Collector _collector = Collector();

  CurrentlyPlaying _currentlyPlaying;
  CurrentlyPlaying get currentlyPlaying => _currentlyPlaying;

  List<TrackSummary> _currentSongList = [];
  int _currentSongIndex = 0;

  /// NOTE: Property used to track the most recent choice between
  ///       previous and next track selection. Next track is marked as 1,
  ///       whereas next track is marked with -1. The 0 value stands as default and
  ///       is useful inside CurrentlyPlayingLabel widget to default to forward animation
  int _trackChangeDelta = 0;
  int get trackChangeDelta => _trackChangeDelta;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int _volumeLevel = 0;
  int get volumeLevel => _volumeLevel;

  MusicCategoryType _lastSelectedCategory = MusicCategoryType.albums;
  MusicCategoryType get lastSelectedCategory => _lastSelectedCategory;

  UnmodifiableListView<InteractiveItem> get recentlyPlayedItems =>
      UnmodifiableListView(_collector.recentlyPlayedItems);
  UnmodifiableListView<InteractiveItem> get pinnedItems =>
      UnmodifiableListView(_collector.pinnedItems);
  UnmodifiableListView<InteractiveItem> get newlyAddedItems =>
      UnmodifiableListView(_collector.newlyAddedItems);
  UnmodifiableListView<AlbumSummary> get allAlbums =>
      UnmodifiableListView(_collector.allAlbums);
  UnmodifiableListView<GenreSummary> get allGenres =>
      UnmodifiableListView(_collector.allGenres);
  UnmodifiableListView<ArtistSummary> get allArtists =>
      UnmodifiableListView(_collector.allArtists);

  GlobalModalState() {
    initializeStore();
  }

  Future<void> initializeStore() async {
    await _collector.initializeCollector();

    RustMessages.sendVolumeChangeEvent(_volumeLevel.roundToDouble());

    QueueChange.rustSignalStream.listen((rustSignal) {
      final queueChangeEvent = rustSignal.message;

      console.log("Got message from rust ${queueChangeEvent.currentRustIndex}",
          customTags: ["GLOBAL STATE"]);

      _currentSongIndex = queueChangeEvent.currentRustIndex;
      _currentlyPlaying = (
        album: _currentlyPlaying!.album,
        song: _currentSongList[_currentSongIndex]
      );

      // Capture that Rust played next track in queue
      _trackChangeDelta = 1;
      notifyListeners();
    });

    notifyListeners();
  }

  void updateCurrentlyPlaying(AlbumSummary album) {
    if (album.album_name == _currentlyPlaying?.album.album_name) return;
    album.getTracks().then(
      (value) {
        _currentlyPlaying = (album: album, song: value.first);
        _isPlaying = true;
        _currentSongList = value;
        _currentSongIndex = 0;
        updateRecentlyPlayedItems(album);
        RustMessages.sendPlayPauseActionEvent(
          PlayPauseRustActionEnum.cleanQueueAction,
          paths: _currentSongList.map((e) => e.path_to_filename).toList(),
        );
      },
    );
    // No need for notifyListeners, above will take care of that
  }

  void updateRecentlyPlayedItems(AlbumSummary album) {
    _collector.updateRecentlyPlayedItems(album).then((_) => notifyListeners());
  }

  void playNextPrevSong(int delta) {
    console.log(
      "SongChange Event: { delta: $delta prev: $_currentSongIndex}",
      customTags: ["GLOBAL STATE"],
    );

    final trackIndex = _getNextPrevTrackIndex(delta);
    if (trackIndex != -1) {
      _currentSongIndex = trackIndex;

      RustMessages.sendPlayPauseActionEvent(
        delta > 0
            ? PlayPauseRustActionEnum.nextAction
            : PlayPauseRustActionEnum.previousAction,
      );

      _currentlyPlaying = (
        album: _currentlyPlaying!.album,
        song: _currentSongList[_currentSongIndex]
      );
      _isPlaying = true;
      // Capture user selection of prev/next track selection
      _trackChangeDelta = delta;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    final action = isPlaying
        ? PlayPauseRustActionEnum.pauseAction
        : PlayPauseRustActionEnum.resumeAction;
    RustMessages.sendPlayPauseActionEvent(action);
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void changeVolumeLevel(int delta) {
    console.log("VolumeChange Event: { delta: $delta prev: $_volumeLevel}",
        customTags: ["GLOBAL STATE"]);

    if (delta > 0) {
      if (_volumeLevel <= 29) {
        _volumeLevel += 1;
        RustMessages.sendVolumeChangeEvent(_volumeLevel.roundToDouble());
        notifyListeners();
      }
    } else {
      if (_volumeLevel > 0) {
        _volumeLevel -= 1;
        RustMessages.sendVolumeChangeEvent(_volumeLevel.roundToDouble());
        notifyListeners();
      }
    }
  }

  void setLastSelectedCategory(MusicCategoryType category) {
    _lastSelectedCategory = category;
    notifyListeners();
  }

  void navigateToCategory(int delta) {
    final nextCategory =
        MusicCategoryType.getNextPrevCategory(delta, _lastSelectedCategory);
    _lastSelectedCategory = nextCategory;
    notifyListeners();
  }

  UnmodifiableListView<TrackSummary> getNext3Songs() {
    if (_currentSongList.isEmpty) return UnmodifiableListView([]);

    final absLen = _currentSongList.length;
    final rem = absLen - _currentSongIndex;
    return UnmodifiableListView(
      _currentSongList.slice(
          _currentSongIndex + 1, rem > 4 ? _currentSongIndex + 4 : absLen),
    );
  }

  Future<UnmodifiableListView<AlbumSummary>> getAlbumsFromIds(
      List<int> album_ids) async {
    return _collector.getAlbumsFromIds(album_ids);
  }

  int _getNextPrevTrackIndex(int delta) {
    int nextPrevIndex = -1;
    if (_currentSongList.isNotEmpty && _currentlyPlaying != null) {
      if (delta > 0) {
        nextPrevIndex = _currentSongList.length - 1 < _currentSongIndex + 1
            ? 0
            : _currentSongIndex + 1;
      } else {
        nextPrevIndex = _currentSongIndex - 1 < 0
            ? _currentSongList.length - 1
            : _currentSongIndex - 1;
      }
    }
    return nextPrevIndex;
  }
}
