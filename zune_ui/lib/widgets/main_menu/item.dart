part of main_menu;

class MenuItem extends StatelessWidget {
  final String text;
  final List<String> subTextItems;
  final bool hasIcon;
  final void Function(Offset target)? onTapHandler;
  final GlobalKey _key = GlobalKey();

  MenuItem({
    super.key,
    this.hasIcon = false,
    required this.text,
    this.subTextItems = const [],
    this.onTapHandler,
  });

  void _onTapHandler() {
    if (onTapHandler == null) return;
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final widgetPosition = renderBox.localToGlobal(Offset.zero);
      onTapHandler!(widgetPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasIcon)
                OnHover(
                  builder: (isHovered) => const CircleWidget(
                    size: 36,
                    borderWidth: 2,
                    margin: EdgeInsets.only(left: 14, right: 14),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              OnHover(
                builder: (isHovered) => Padding(
                  padding: hasIcon
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(
                          left: 16 + 32 + 16,
                        ),
                  child: GestureDetector(
                    onTap: _onTapHandler,
                    child: Text(
                      key: _key,
                      text.toLowerCase(),
                      style: Styles.item.copyWith(
                        shadows: [
                          if (isHovered)
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.white,
                              offset: Offset(1, 1),
                            ),
                        ],
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 16 + 32 + 16 + 4),
            child: Row(
              children: subTextItems
                  .map(
                    (subText) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        subText.toUpperCase(),
                        style: Styles.subItem,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
