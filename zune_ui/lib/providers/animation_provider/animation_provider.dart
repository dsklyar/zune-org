part of animation_provider;

enum EventType {
  unmountEvent,
  mountEvent,
}

/// NOTE: This is provider responsible for managing animation
///       execution across multiple widgets globally.
///
///       The key purpose is to schedule animation updates based
///       on the EventType and group Future-like calls together
///       to be executed when combined animation is required.
///
///       Example: Unmounting event
///       Multiple widgets can register their unmount animations
///       with this provider. Each widget registers an unmount event
///       with a callback which will perform an animation change such
///       as forward/reverse. These events will be executed in order*
///       and followed by last call in executeWith callback.

class MusicPlayerAnimationProvider extends InheritedWidget {
  final Map<EventType, List<Future<void> Function()>> _map = {};

  MusicPlayerAnimationProvider({
    super.key,
    required super.child,
  });

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

  void clear(EventType? key) {
    if (key != null) {
      _map.remove(key);
    } else {
      _map.clear();
    }
  }

  void executeWith(Future<void> Function() finalAction) async {
    for (final actions in _map.values) {
      await Future.wait(
        actions.map((action) async {
          try {
            await action();
          } catch (e) {
            console.error(e, customTags: ["animation_provider"]);

            /// NOTE: Ignore errors from disposed animation controllers
            ///       or other widget lifecycle issues. This can happen when
            ///       widgets are disposed before the animation sequence executes.
          }
        }),
      );
    }
    await finalAction();

    /// NOTE: Clear registered callbacks after execution to prevent
    ///       accumulation of stale callbacks from disposed widgets.
    _map.clear();
  }

  @override
  bool updateShouldNotify(MusicPlayerAnimationProvider oldWidget) {
    return true;
  }
}
