part of music_common_widgets;

class EmptyCategory extends StatelessWidget {
  const EmptyCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "no items.".toUpperCase(),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
