import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/messages/all.dart';

class GlobalModalState extends ChangeNotifier {
  // For Pinned/New/Recently items allow up to 8 items in render
  static const int _maxAllowedItemsCount = 8;

  ({AlbumModel album, SongModel song})? _currentlyPlaying;
  ({AlbumModel album, SongModel song})? get currentlyPlaying =>
      _currentlyPlaying;

  List<SongModel> _currentSongList = [];
  int _currentSongIndex = 0;

  /// Property used to track the most recent choice between
  /// previous and next track selection. Next track is marked as 1,
  /// whereas next track is marked with -1. The 0 value stands as default and
  /// is useful inside CurrentlyPlayingLabel widget to default to forward animation
  int _trackChangeDelta = 0;
  int get trackChangeDelta => _trackChangeDelta;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int _volumeLevel = 0;
  int get volumeLevel => _volumeLevel;

  List<AlbumModel> _newlyAddedItems = [];
  final List<AlbumModel> _pinnedItems = [];
  final List<AlbumModel> _recentlyPlayedItems = [];

  UnmodifiableListView<AlbumModel> get pinnedItems =>
      UnmodifiableListView(_pinnedItems);
  UnmodifiableListView<AlbumModel> get newlyAddedItems =>
      UnmodifiableListView(_newlyAddedItems);
  UnmodifiableListView<AlbumModel> get recentlyPlayedItems =>
      UnmodifiableListView(_recentlyPlayedItems);

  GlobalModalState() {
    initializeStore();
  }

  Future<void> initializeStore() async {
    // TODO: On intial load of DB and music this will error:
    _newlyAddedItems = (await AlbumModel.readAll()).slice(0, 8);
    VolumeChange(max: 30, value: _volumeLevel.roundToDouble())
        .sendSignalToRust();
    QueueChange.rustSignalStream.listen((rustSignal) {
      final queueChangeEvent = rustSignal.message;
      print("Got message from rust ${queueChangeEvent.currentRustIndex}");
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

  void updateCurrentlyPlaying(AlbumModel album) {
    if (album.album_name == _currentlyPlaying?.album.album_name) return;
    album.getSongs().then(
      (value) {
        _currentlyPlaying = (album: album, song: value.first);
        _isPlaying = true;
        _currentSongList = value;
        _currentSongIndex = 0;
        updateRecentlyPlayedItems(album);
        PlayPauseTrackAtPath(
          action: "clean_queue_action",
          paths: _currentSongList.map((e) => e.path_to_filename).toList(),
        ).sendSignalToRust();
      },
    );
    // No need for notifyListeners, above will take care of that
  }

  void updateRecentlyPlayedItems(AlbumModel album) {
    if (_recentlyPlayedItems.length >= _maxAllowedItemsCount) {
      _recentlyPlayedItems.removeLast();
    } else if (_recentlyPlayedItems.contains(album)) {
      _recentlyPlayedItems.remove(album);
    }
    _recentlyPlayedItems.insert(0, album);
    notifyListeners();
  }

  void updateNewlyAddedItems(AlbumModel album) {
    if (_newlyAddedItems.length >= _maxAllowedItemsCount) {
      _newlyAddedItems.removeLast();
    } else if (_newlyAddedItems.contains(album)) {
      _newlyAddedItems.remove(album);
    }
    _newlyAddedItems.insert(0, album);
    notifyListeners();
  }

  void updatePinnedItems(AlbumModel album) {
    if (_pinnedItems.length >= _maxAllowedItemsCount) {
      _pinnedItems.removeLast();
    } else if (_pinnedItems.contains(album)) {
      _pinnedItems.remove(album);
    }
    _pinnedItems.insert(0, album);
    notifyListeners();
  }

  void playNextPrevSong(int delta) {
    if (kDebugMode) {
      print("SongChange Event: { delta: $delta prev: $_currentSongIndex}");
    }

    final trackIndex = _getNextPrevTrackIndex(delta);
    if (trackIndex != -1) {
      _currentSongIndex = trackIndex;
      PlayPauseTrackAtPath(
              action: delta > 0 ? "next_action" : "previous_action")
          .sendSignalToRust();

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

  void updateIsPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  void changeVolumeLevel(int delta) {
    if (kDebugMode) {
      print("VolumeChange Event: { delta: $delta prev: $_volumeLevel}");
    }
    if (delta > 0) {
      if (_volumeLevel <= 29) {
        _volumeLevel += 1;
        VolumeChange(max: 30, value: _volumeLevel.roundToDouble())
            .sendSignalToRust();
        notifyListeners();
      }
    } else {
      if (_volumeLevel > 0) {
        _volumeLevel -= 1;
        VolumeChange(max: 30, value: _volumeLevel.roundToDouble())
            .sendSignalToRust();
        notifyListeners();
      }
    }
  }

  UnmodifiableListView<SongModel> getNext3Songs() {
    if (_currentSongList.isEmpty) return UnmodifiableListView([]);

    final absLen = _currentSongList.length;
    final rem = absLen - _currentSongIndex;
    return UnmodifiableListView(
      _currentSongList.slice(
          _currentSongIndex + 1, rem > 4 ? _currentSongIndex + 4 : absLen),
    );
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
