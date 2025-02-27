import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:zune_ui/database/index.dart';
import 'package:zune_ui/enums/index.dart';
import 'package:zune_ui/messages/all.dart';
import 'package:zune_ui/widgets/custom/debug_print.dart';

final console = DebugPrint().register(DebugComponent.globalState);

typedef CurrentlyPlaying = ({AlbumModelSummary album, TrackModel song})?;

class GlobalModalState extends ChangeNotifier {
  // For Pinned/New/Recently items allow up to 8 items in render
  static const int _maxAllowedItemsCount = 20;

  CurrentlyPlaying _currentlyPlaying;
  CurrentlyPlaying get currentlyPlaying => _currentlyPlaying;

  List<TrackModel> _currentSongList = [];
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

  List<AlbumModelSummary> _allAlbums = [];
  List<AlbumModelSummary> _newlyAddedItems = [];
  final List<InteractiveItem> _pinnedItems = [];
  final List<InteractiveItem> _recentlyPlayedItems = [];

  UnmodifiableListView<InteractiveItem> get pinnedItems =>
      UnmodifiableListView(_pinnedItems);
  UnmodifiableListView<AlbumModelSummary> get newlyAddedItems =>
      UnmodifiableListView(_newlyAddedItems);
  UnmodifiableListView<InteractiveItem> get recentlyPlayedItems =>
      UnmodifiableListView(_recentlyPlayedItems);
  UnmodifiableListView<AlbumModelSummary> get allAlbums =>
      UnmodifiableListView(_allAlbums);

  MusicCategoryType _lastSelectedCategory = MusicCategoryType.albums;
  MusicCategoryType get lastSelectedCategory => _lastSelectedCategory;

  GlobalModalState() {
    initializeStore();
  }

  Future<void> initializeStore() async {
    final allAlbums = await AlbumModelSummary.readAll();
    _allAlbums = allAlbums;
    _allAlbums.sort((a, b) => a.album_name.compareTo(b.album_name));

    /// TODO: Need to actually track newly added tracks
    _newlyAddedItems = allAlbums.length > _maxAllowedItemsCount
        ? allAlbums.slice(0, _maxAllowedItemsCount)
        : allAlbums;

    VolumeChange(max: 30, value: _volumeLevel.roundToDouble())
        .sendSignalToRust();
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

  void updateCurrentlyPlaying(AlbumModelSummary album) {
    if (album.album_name == _currentlyPlaying?.album.album_name) return;
    album.getTracks().then(
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

  void updateRecentlyPlayedItems(AlbumModelSummary album) {
    if (_recentlyPlayedItems.length >= _maxAllowedItemsCount) {
      _recentlyPlayedItems.removeLast();
    } else if (_recentlyPlayedItems.contains(album)) {
      _recentlyPlayedItems.remove(album);
    }
    _recentlyPlayedItems.insert(0, album);
    notifyListeners();
  }

  void updateNewlyAddedItems(AlbumModelSummary album) {
    if (_newlyAddedItems.length >= _maxAllowedItemsCount) {
      _newlyAddedItems.removeLast();
    } else if (_newlyAddedItems.contains(album)) {
      _newlyAddedItems.remove(album);
    }
    _newlyAddedItems.insert(0, album);
    notifyListeners();
  }

  void updatePinnedItems(AlbumModelSummary album) {
    if (_pinnedItems.length >= _maxAllowedItemsCount) {
      _pinnedItems.removeLast();
    } else if (_pinnedItems.contains(album)) {
      _pinnedItems.remove(album);
    }
    _pinnedItems.insert(0, album);
    notifyListeners();
  }

  void playNextPrevSong(int delta) {
    console.log("SongChange Event: { delta: $delta prev: $_currentSongIndex}",
        customTags: ["GLOBAL STATE"]);

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
    console.log("VolumeChange Event: { delta: $delta prev: $_volumeLevel}",
        customTags: ["GLOBAL STATE"]);

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

  UnmodifiableListView<TrackModel> getNext3Songs() {
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
}
