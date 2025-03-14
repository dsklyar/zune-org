part of music_common_widgets;

const DEFAULT_HEIGHT = 44.0;

typedef ParallaxConfiguration = ({
  double x,
  double y,
  double velocity,
  int signedDirection,
});

typedef WidgetConfig<Item> = ({
  ParallaxConfiguration parallaxConfig,
  Widget Function(BuildContext context, Item data) builder
});

class ListItemWrapper<Item> extends StatelessWidget {
  final Item data;
  final double height;
  final List<WidgetConfig<Item>> widgetConfigs;

  const ListItemWrapper({
    super.key,
    this.height = DEFAULT_HEIGHT,
    required this.data,
    required this.widgetConfigs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Flow(
        /// NOTE: Need to remove clipping here because the play button
        ///       during translation inside the Flow
        clipBehavior: Clip.none,
        delegate: ParallaxFlowDelegate(
          itemContext: context,
          scrollable: Scrollable.of(context),
          configuration: widgetConfigs
              .map((config) => config.parallaxConfig)
              .toList()
              .asMap(),
        ),
        children: widgetConfigs
            .map((config) => config.builder(context, data))
            .toList(),
      ),
    );
  }
}

/// NOTE: This code is taken & slightly modified from:
///       -> https://docs.flutter.dev/cookbook/effects/parallax-scrolling
///
class ParallaxFlowDelegate extends FlowDelegate {
  final BuildContext itemContext;
  final ScrollableState scrollable;
  final Map<int, ParallaxConfiguration> configuration;

  ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
    required this.configuration,
  }) : super(repaint: scrollable.position);

  @override
  void paintChildren(FlowPaintingContext context) {
    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = itemContext.findRenderObject() as RenderBox;

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Since these items are lazy loaded by parent's GridView
    // here is the logic to get current item global scrolled offset:
    final listItemOffset = listItemBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    // Basically, take the items offset and divide by scrollable viewport dimension e.g. 360.
    // This should give a ratio which is clamped [-1, 1] of how far the item was scrolled.
    // Trying to encode scale/translate here is counter intuitive so its best to do translate in the widget.
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(-1.0, 1.0);

    for (int i = 0; i < context.childCount; i++) {
      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(
            configuration[i]!.x,
            configuration[i]!.y +
                scrollFraction *
                    configuration[i]!.velocity *
                    configuration[i]!.signedDirection,
            0.0,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        itemContext != oldDelegate.itemContext;
  }
}
