part of player_page;

class TrackActionsControls extends StatelessWidget {
  const TrackActionsControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleWidget(
            size: 32,
            borderColor: Colors.white.withAlpha(200),
            child: Icon(
              Icons.shuffle_rounded,
              color: Colors.white.withAlpha(50),
              size: 20,
            ),
          ),
          CircleWidget(
            size: 32,
            borderColor: Colors.white.withAlpha(200),
            child: Icon(
              Icons.refresh_rounded,
              color: Colors.white.withAlpha(50),
              size: 20,
            ),
          ),
          CircleWidget(
            size: 32,
            borderColor: Colors.white.withAlpha(200),
            child: Icon(
              Icons.favorite,
              color: Colors.white.withAlpha(50),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
