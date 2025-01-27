part of controls_page;

enum PlaybackControlTypeEnum { rewind, fastForward }

class PlaybackControl extends StatelessWidget {
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final bool isActive;
  final PlaybackControlTypeEnum type;

  const PlaybackControl({
    super.key,
    required this.type,
    required this.onTapDown,
    required this.onTapUp,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: Icon(
        shadows: [
          if (isActive)
            const Shadow(
              blurRadius: 10.0,
              color: Colors.white,
            ),
        ],
        type == PlaybackControlTypeEnum.rewind
            ? Icons.fast_rewind
            : Icons.fast_forward,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}
