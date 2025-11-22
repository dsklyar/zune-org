part of music_common_widgets;

const double PLAY_BUTTON_SIZE = 36.0;

class ListTilePlayButton extends StatelessWidget {
  const ListTilePlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: // Play button on top
            const CircleWidget(
          size: PLAY_BUTTON_SIZE,
          borderWidth: 2,
          child: Icon(
            Icons.play_arrow,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
