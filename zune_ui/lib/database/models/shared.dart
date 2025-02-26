part of database;

abstract class InteractiveItem {
  Future<void> addToQuickplay();
  Future<void> removeFromQuickplay();
}

abstract class PlayableItem extends InteractiveItem {
  Future<void> addToNowPlaying();
}
