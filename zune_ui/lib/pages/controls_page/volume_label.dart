part of controls_page;

class VolumeLabel extends StatelessWidget {
  final double topPosition;
  final double leftPosition;

  const VolumeLabel({
    super.key,
    required this.topPosition,
    required this.leftPosition,
  });

  String convertToString(int volumeLevel) {
    return volumeLevel < 10 ? "0$volumeLevel" : volumeLevel.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: Selector<GlobalModalState, int>(
        selector: (context, state) => state.volumeLevel,
        builder: (context, volumeLevel, child) => FadeAnimationWrapper(
          duration: const Duration(milliseconds: 300),
          delayBeforeFadeOut: const Duration(seconds: 2),
          // Ignore pointer here so that events from backdrop would be captured in the stack
          child: IgnorePointer(
            child: Text(
              convertToString(volumeLevel),
              style: Styles.volumeLabel,
            ),
          ),
        ),
      ),
    );
  }
}
