part of music_common_widgets;

const LIST_GAP = 26.0;

class ListWrapper<ItemList extends Iterable<Item>, Item, RenderItem>
    extends StatefulWidget {
  final double listGap;
  final Iterable<RenderItem> Function(
    ItemList items, {
    ScrollController? scrollController,
  })? itemsMiddleware;
  final ItemList Function(GlobalModalState state) selector;
  final Widget Function(BuildContext context, RenderItem item) itemBuilder;

  const ListWrapper({
    super.key,
    this.itemsMiddleware,
    this.listGap = LIST_GAP,
    required this.selector,
    required this.itemBuilder,
  });

  @override
  State<ListWrapper<ItemList, Item, RenderItem>> createState() =>
      _ListWrapperState<ItemList, Item, RenderItem>();
}

class _ListWrapperState<ItemList extends Iterable<Item>, Item, RenderItem>
    extends State<ListWrapper<ItemList, Item, RenderItem>> {
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, ItemList>(
      selector: (context, state) => widget.selector(state),

      /// NOTE: Using custom over scroll wrapper to allow user long swipe
      ///       across the scroll container to return to the top/bottom
      ///       of the list.
      builder: (context, data, child) {
        if (data.isEmpty) return const EmptyCategory();

        return OverScrollWrapper(
          /// NOTE: Using ListView separated her in order to configure
          ///       spaced out list item vertical view.
          builder: (scrollController, scrollPhysics) {
            final items = widget.itemsMiddleware != null
                ? widget.itemsMiddleware!(
                    data,
                    scrollController: scrollController,
                  )
                : data as Iterable<RenderItem>;

            return ListView.separated(
              // Over-scroll logic props derived from OverScrollWrapper
              controller: scrollController,
              physics: scrollPhysics,
              // Rest of ListView props:
              scrollDirection: Axis.vertical,
              padding: parent.CATEGORY_PADDING,
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(
                height: widget.listGap,
              ),
              itemBuilder: (context, index) => widget.itemBuilder(
                context,
                items.elementAt(index),
              ),
            );
          },
        );
      },
    );
  }
}
