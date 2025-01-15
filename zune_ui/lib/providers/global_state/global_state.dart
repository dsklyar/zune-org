import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:zune_ui/database/index.dart';

class GlobalModalState extends ChangeNotifier {
  // For Pinned/New/Recently items allow up to 8 items in render
  static const int _maxAllowedItemsCount = 8;

  ({AlbumModel album, SongModel song})? _currentlyPlaying;
  ({AlbumModel album, SongModel song})? get currentlyPlaying =>
      _currentlyPlaying;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

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
    _newlyAddedItems = (await AlbumModel.readAll()).slice(0, 8);
    notifyListeners();
  }

  void updateCurrentlyPlaying(AlbumModel album) {
    if (album.album_name == _currentlyPlaying?.album.album_name) return;
    album.getSongs().then((value) {
      _currentlyPlaying = (album: album, song: value.first);
      _isPlaying = true;
      updateRecentlyPlayedItems(album);
    });
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
}
