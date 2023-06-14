import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import '../effects/index.dart';
import './styles.dart';

Widget circle = Container(
  margin: const EdgeInsets.only(left: 16, right: 16),
  height: 32,
  width: 32,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      width: 2,
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
  ),
);

class MenuItem extends StatelessWidget {
  final String text;
  final List<String> subTextItems;
  final bool hasIcon;

  const MenuItem({
    super.key,
    this.hasIcon = false,
    required this.text,
    this.subTextItems = const [],
  });

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
                  builder: (isHovered) => circle,
                ),
              OnHover(
                builder: (isHovered) => Padding(
                  padding: hasIcon
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(
                          left: 16 + 32 + 16,
                        ),
                  child: Text(
                    text.toLowerCase(),
                    style: Styles.item.copyWith(
                      shadows: [
                        if (isHovered)
                          const Shadow(
                            blurRadius: 10.0,
                            color: Color.fromARGB(255, 255, 255, 255),
                            offset: Offset(1, 1),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ...subTextItems.mapIndexed(
                (index, subText) => Padding(
                  padding: index == 0
                      ? const EdgeInsets.only(left: 16 + 32 + 16 + 10)
                      : const EdgeInsets.only(left: 2),
                  child: Text(
                    subText.toUpperCase(),
                    style: Styles.subItem,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
