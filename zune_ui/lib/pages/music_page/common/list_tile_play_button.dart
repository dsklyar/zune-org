part of music_common_widgets;

class ListTilePlayButton extends StatelessWidget {
  const ListTilePlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: CircleWidget(
        size: 36,
        borderWidth: 2,
        child: Icon(
          Icons.play_arrow,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
