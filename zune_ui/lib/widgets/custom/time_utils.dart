import 'dart:async';
import 'package:zune_ui/widgets/custom/debug_print.dart';

typedef VoidCallback = void Function();

class Debouncer {
  final Duration duration;
  final String? debugName;
  Console? logger = DebugPrint().register(DebugComponent.timing);
  Timer? _timer;

  Debouncer({required this.duration, this.debugName, this.logger});

  void call(VoidCallback action) {
    cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    if (_timer != null) {
      if (logger != null) {
        logger!.log(
          "Canceling '${debugName ?? "generic"}' debouncer",
          customTags: ["debouncer", debugName ?? "hidden"],
        );
      }
      _timer?.cancel();
      _timer = null;
    }
  }
}

class Repeater {
  final Duration duration;
  final String? debugName;
  Console? logger = DebugPrint().register(DebugComponent.timing);

  Timer? _timer;
  Repeater({required this.duration, this.debugName, this.logger});

  void repeat(VoidCallback action) {
    cancel();
    _timer = Timer.periodic(duration, (timer) {
      action();
    });
  }

  void cancel() {
    if (_timer != null) {
      if (logger != null) {
        logger!.log(
          "Canceling '${debugName ?? "generic"}' repeater",
          customTags: ["repeater", debugName ?? "hidden"],
        );
      }
      _timer!.cancel();
      _timer = null;
    }
  }
}

class Throttler {
  final Duration duration;
  final String? debugName;
  Console? logger = DebugPrint().register(DebugComponent.timing);
  Timer? _timer;

  Throttler({required this.duration, this.debugName, this.logger});

  void run(VoidCallback action) {
    // Prevents action if the timer is still active.
    if (_timer?.isActive ?? false) {
      return;
    }

    // Execute the action immediately.
    action();
    _timer = Timer(duration, () {}); // Set up the timer.
  }

  void cancel() {
    if (logger != null) {
      logger!.log(
        "Canceling '${debugName ?? "generic"}' throttler",
        customTags: ["throttler", debugName ?? "hidden"],
      );
    }
    _timer?.cancel();
  }
}
