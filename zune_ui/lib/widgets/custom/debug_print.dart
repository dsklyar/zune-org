import 'package:flutter/foundation.dart';

enum DebugComponent {
  controlsPage("Controls Page"),
  musicPage("Music Page"),
  playerPage("Player Page"),
  splashPage("Splash Page"),
  overlaysPage("Overlays Page"),
  searchIndexPage("Search Index Page"),
  database("SQLite Database"),
  globalState("Global State"),
  timing("Timing Components"),
  animation("Animation Components");

  const DebugComponent(this.name);
  final String name;
}

class DebugPrint {
  // Private constructor
  DebugPrint._privateConstructor();
  // The single instance of the class
  static final DebugPrint _instance = DebugPrint._privateConstructor();

  static final List<String> _hiddenComponents = [
    "hidden",
    // DebugComponent.controlsPage.name
    // "debouncer",
    // "repeater"
  ];

  // Factory constructor to return the same instance
  factory DebugPrint() {
    return _instance;
  }

  // Example method
  Console register(DebugComponent context) {
    return Console(context);
  }

  bool isHidden(List<String> flags) {
    return flags.fold(false, (acc, flag) {
      if (acc) return acc;
      return _hiddenComponents.contains(flag);
    });
  }
}

class Console {
  final DebugComponent context;
  Console(this.context);
  void log(Object? object, {List<String> customTags = const []}) {
    if (DebugPrint._instance.isHidden([context.name, ...customTags])) return;
    _compute(
        "[${context.name}]${customTags.isNotEmpty ? "-[${customTags.join("_")}]" : ""}-[LOG]: $object");
  }

  void error(Object? object, {List<String> customTags = const []}) {
    if (DebugPrint._instance.isHidden([context.name, ...customTags])) return;
    _compute(
        "[${context.name}]${customTags.isNotEmpty ? "-[${customTags.join("_")}]" : ""}-[ERROR]: $object");
  }

  void _compute(String copy) {
    if (kDebugMode) {
      print(copy);
    }
  }
}
