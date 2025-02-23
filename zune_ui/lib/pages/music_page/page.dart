part of music_page;

class MusicPage extends StatefulWidget {
  final Size size;
  final Offset startingOffset;
  const MusicPage({
    super.key,
    required this.startingOffset,
    required this.size,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void _onReturnTapHandler() {
    final musicPlayerAnimationContext =
        MusicPlayerAnimationProvider.of(context);

    musicPlayerAnimationContext?.executeWith(() async {
      if (context.mounted) {
        context.go(ApplicationRoute.home.route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuItemWrapper(
      startingOffset: widget.startingOffset,
      displayText: "music",
      size: widget.size,
      onTapHandler: _onReturnTapHandler,
      child: const Column(
        children: [
          SizedBox(
            height: 64,
            child: SizedBox.shrink(),
          ),
          MusicCategoriesWrapper(),
          ViewSelector(),
        ],
      ),
    );
  }
}

class MusicPageWrapped extends StatelessWidget {
  final Size size;
  final Offset startingOffset;
  const MusicPageWrapped({
    super.key,
    required this.startingOffset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return MusicPlayerAnimationProvider(
      child: MusicPage(
        size: size,
        startingOffset: startingOffset,
      ),
    );
  }
}
