part of global_state;

class RustMessages {
  static sendVolumeChangeEvent(
    double volumeLevel, {
    double maxLevel = 30,
  }) {
    return VolumeChange(
      max: maxLevel,
      value: volumeLevel,
    ).sendSignalToRust();
  }

  static sendPlayPauseActionEvent(
    PlayPauseRustActionEnum action, {
    List<String>? paths,
  }) {
    return PlayPauseTrackAtPath(
      action: action.value,
      paths: paths,
    ).sendSignalToRust();
  }
}
