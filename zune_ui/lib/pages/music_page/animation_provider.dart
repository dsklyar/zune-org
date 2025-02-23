part of music_page;

enum EventType {
  unmountEvent,
  mountEvent,
}

/// NOTE: This is provider responsible for managing animation
///       execution across multiple Music Player widgets.
///
///       The key purpose is to schedule animation updates based
///       on the EventType and group Future-like calls together
///       to be executed when combined animation is required.
///
///       Example: Unmounting event
///       Both AlbumGrid & MusicCategories widgets have their
///       respective unmount animation driven by AnimationControllers.
///       Each widget, registers an unmount event with a callback which
///       will perform a animation change such as forward/reverse. These
///       events will be executed in order* and followed by last call in
///       executeWith callback.
///

class MusicPlayerAnimationProvider extends InheritedWidget {
  final Map<EventType, List<Future<void> Function()>> _map = {};

  MusicPlayerAnimationProvider({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static MusicPlayerAnimationProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MusicPlayerAnimationProvider>();
  }

  void register(EventType key, Future<void> Function() cb) {
    if (_map.containsKey(key)) {
      _map[key]?.add(cb);
    } else {
      _map[key] = [cb];
    }
  }

  void executeWith(Future<void> Function() finalAction) async {
    for (final actions in _map.values) {
      await Future.wait(actions.map((action) => action()));
    }
    await finalAction();
  }

  @override
  bool updateShouldNotify(MusicPlayerAnimationProvider oldWidget) {
    return true;
  }
}
