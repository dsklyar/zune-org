part of support_menu;

class ItemsColumn extends StatelessWidget {
  final String title;
  final UnmodifiableListView<InteractiveItem> items;
  final void Function(InteractiveItem) onClickHandler;
  final bool isLast;

  const ItemsColumn({
    super.key,
    required this.title,
    required this.items,
    required this.onClickHandler,
    this.isLast = false,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.tileText,
        ),
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          direction: Axis.horizontal,
          children: items.map(
            (item) {
              if (item is AlbumModel) {
                return AlbumTile(
                  album: item,
                  onAlbumClick: onClickHandler,
                );
              }
              return SizedBox.shrink();
            },
          ).toList(),
        ),
        const SizedBox(height: 32),
        if (isLast) const SizedBox(height: 64),
      ],
    );
  }
}
