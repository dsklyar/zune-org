part of enums;

enum PlayPauseRustActionEnum {
  resumeAction("resume_action"),
  pauseAction("pause_action"),
  nextAction("next_action"),
  previousAction("previous_action"),
  playAction("play_action"),
  cleanQueueAction("clean_queue_action");

  final String value;
  const PlayPauseRustActionEnum(this.value);
}
