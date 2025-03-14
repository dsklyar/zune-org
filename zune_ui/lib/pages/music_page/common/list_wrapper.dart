part of music_common_widgets;

const LIST_GAP = 26.0;

class ListWrapper<ItemList extends Iterable<Item>, Item>
    extends StatefulWidget {
  final ItemList Function(ItemList items)? itemsReducer;
  final ItemList Function(GlobalModalState state) selector;
  final Widget Function(BuildContext context, Item item) itemBuilder;

  const ListWrapper({
    super.key,
    this.itemsReducer,
    required this.selector,
    required this.itemBuilder,
  });

  @override
  State<ListWrapper<ItemList, Item>> createState() =>
      _ListWrapperState<ItemList, Item>();
}

class _ListWrapperState<ItemList extends Iterable<Item>, Item>
    extends State<ListWrapper<ItemList, Item>> {
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, ItemList>(
      selector: (context, state) => widget.selector(state),

      /// NOTE: Using custom over scroll wrapper to allow user long swipe
      ///       across the scroll container to return to the top/bottom
      ///       of the list.
      builder: (context, data, child) {
        final items =
            widget.itemsReducer != null ? widget.itemsReducer!(data) : data;

        return OverScrollWrapper(
          /// NOTE: Using ListView separated her in order to configure
          ///       spaced out list item vertical view.
          builder: (scrollController, scrollPhysics) => ListView.separated(
            // Over-scroll logic props derived from OverScrollWrapper
            controller: scrollController,
            physics: scrollPhysics,
            // Rest of ListView props:
            scrollDirection: Axis.vertical,
            padding: parent.CATEGORY_PADDING,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: LIST_GAP,
            ),
            itemBuilder: (context, index) =>
                widget.itemBuilder(context, items.elementAt(index)),
          ),
        );
      },
    );
  }
}
