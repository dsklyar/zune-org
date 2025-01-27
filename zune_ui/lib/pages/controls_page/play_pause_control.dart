part of controls_page;

class PlayPauseControl extends StatelessWidget {
  final void Function() onTap;

  final bool isActive;

  const PlayPauseControl({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalModalState>(
      builder: (context, state, child) => GestureDetector(
        onTap: onTap,
        child: CircleWidget(
          size: 76,
          borderWidth: 4,
          child: Icon(
            shadows: [
              if (isActive)
                const Shadow(
                  blurRadius: 10.0,
                  color: Colors.white,
                ),
            ],
            state.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }
}
