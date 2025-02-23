part of music_categories_widget;

const DEFAULT_SPACING = 8;
final CATEGORIES_LENGTH = MusicCategoryType.values.length;

class MusicCategories extends StatefulWidget {
  const MusicCategories({
    super.key,
  });

  @override
  State<MusicCategories> createState() => _MusicCategoriesState();
}

class _MusicCategoriesState extends State<MusicCategories>
    with SingleTickerProviderStateMixin {
  late GlobalModalState _globalState;

  late final AnimationController _controller;

  final Map<MusicCategoryType, GlobalKey> _categoryKeys = {};
  late MusicCategoryType _activeCategory;

  // State used for the translation of the categories based on user dragging/animation
  double _xOffset = 0;
  // State used for tracking if the categories are being dragged (to prevent edge cases)
  bool _isDragged = false;
  // State used for setting boundaries for how far +- categories can be dragged
  ({double lowerBoundOffset, double upperBoundOffset})? _bounds;

  late Memoized<List<Widget>> _memoizedCategories;

  @override
  void initState() {
    super.initState();
    _globalState = context.read<GlobalModalState>();
    _activeCategory = _globalState.lastSelectedCategory;

    for (var category in MusicCategoryType.values) {
      _categoryKeys[category] = GlobalKey();
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _memoizedCategories = (() => _generateCategories()).memo;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _animateToCategory(_activeCategory, forceUpdate: true);
      },
    );
  }

  /// NOTE: Tracking the change in the last selected category,
  ///       when other widgets e.g. ViewSelector navigates to another category
  ///       need to trigger animation & update state of updated selected category
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// NOTE: Notice watch here listens to the state change
    _globalState = context.watch<GlobalModalState>();

    /// NOTE: Animate to category triggers animation and state update
    _animateToCategory(_globalState.lastSelectedCategory);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapHandler(MusicCategoryType targetCategory) => _animateToCategory(
        targetCategory,
        updateSelectedCategory: true,
      );

  /// NOTE: This method derives widget's width & offset from the 0,0 screen position,
  ///       which is used for slide animation.
  ({double offsetX, double widgetWidth})? _getCategoryMagicData(
    MusicCategoryType targetCategory,
  ) {
    final categoryKey = _categoryKeys[targetCategory];
    if (categoryKey == null || categoryKey.currentContext == null) return null;

    final renderBox =
        categoryKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final offsetX = renderBox.globalToLocal(Offset.zero).dx + DEFAULT_SPACING;
    final widgetWidth = renderBox.size.width;

    return (offsetX: offsetX, widgetWidth: widgetWidth);
  }

  MusicCategoryType _getCategory(
    MusicCategoryType targetCategory, {
    int delta = 0,
  }) {
    final currentCategoryIndex =
        MusicCategoryType.values.indexOf(targetCategory);
    if (currentCategoryIndex + delta >= CATEGORIES_LENGTH) {
      return MusicCategoryType.values[0];
    } else if (currentCategoryIndex + delta < 0) {
      return MusicCategoryType.values[CATEGORIES_LENGTH - 1];
    } else {
      return MusicCategoryType.values[currentCategoryIndex + delta];
    }
  }

  void _animateToCategory(
    MusicCategoryType targetCategory, {
    bool forceUpdate = false,
    bool updateSelectedCategory = false,
  }) {
    // Unless forceUpdate flag is true skip animation to categories which are the same as the current one.
    // This prevents user from clicking on selected category and seeing animation for the same View.
    if (targetCategory == _activeCategory && !forceUpdate) return;

    // Offset needed for deriving the future position during offset + this animation.
    final targetCategoryOffset = _getCategoryMagicData(targetCategory)?.offsetX;
    // Width needed to set the final offset once the animation is done and
    // next category needs to be hidden.
    final previousCategory = _getCategory(targetCategory, delta: -1);
    final previousCategoryWidth =
        _getCategoryMagicData(previousCategory)?.widgetWidth;

    if (targetCategoryOffset == null || previousCategoryWidth == null) return;

    /// NOTE: If this flag is set to true, need to update the global state to trigger
    ///       animation in sibling widgets such as ViewSelector.
    ///
    ///       Most of the callbacks will need to set updateSelectedCategory to true
    ///       except the mounting one in initState() since there is no need to update
    ///       the global state on first mount.
    if (updateSelectedCategory) {
      _globalState.setLastSelectedCategory(
        targetCategory,
      );
    }

    final Animation<double> categoriesOffsetX =
        Tween<double>(begin: _xOffset, end: _xOffset + targetCategoryOffset)
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    void listener() {
      setState(() {
        _xOffset = categoriesOffsetX.value;
      });
    }

    _controller.addListener(listener);
    _controller.forward().then(
      (value) {
        _controller.removeListener(listener);
        _controller.reset();

        setState(() {
          /// NOTE: Since category width is a positive value and offset needs to correctly account for
          ///       the hidden category, multiply by -1 to position the categories.
          _xOffset = -1 * previousCategoryWidth;
          _activeCategory = targetCategory;
          // Since new category is set need to generate new List<Widgets> used for animation
          _memoizedCategories = (() => _generateCategories()).memo;
          // Resetting state to let drag logic to be re-initialized when new events come in
          _bounds = null;
          _isDragged = false;
        });
      },
    );
  }

  List<Widget> _generateCategories() {
    // Get index of widget's active category
    final currentCategoryIndex =
        MusicCategoryType.values.indexOf(_activeCategory);

    /// NOTE:
    /// Since the first category is always hidden so that user can scroll back to it:
    ///         |       Visible Display
    ///         V    _______________________
    /// e.g. genres | [albums] artists play.|.list etc..
    ///             |                       |
    /// Need to derive a safe index starting with the hidden category such that the
    /// category list which is used for generating the array of widgets starts with
    /// correct category hidden off screen.
    ///
    /// If the current category index - 1 is below 0, need to print the last category in the array.
    final overflowCorrectedIndex = currentCategoryIndex - 1 < 0
        ? CATEGORIES_LENGTH - 1
        : currentCategoryIndex - 1;

    // Generate a list if categories according to the safe current index
    // starting from the hidden category
    final list = [
      // Slice the range from safe current index to end of categories list
      ...MusicCategoryType.values
          .getRange(overflowCorrectedIndex, CATEGORIES_LENGTH),
      // Slice the range from the start to the safe current index of categories
      ...MusicCategoryType.values.getRange(0, overflowCorrectedIndex),
    ];

    return list.map(
      (category) {
        return GestureDetector(
          onTap: () => _controller.isAnimating ? {} : _onTapHandler(category),
          child: Text(
            key: _categoryKeys[category],
            category.displayName,
            style: Styles.subtitleFont.copyWith(
              color: _activeCategory == category ? Colors.white : null,
              overflow: TextOverflow.clip,
            ),
          ),
        );
      },
    ).toList();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    /// NOTE: These bounds are derived based on previous category, which is a quick way to assign a
    ///       maximum width that user can scroll. COuld get both prev & next category width but the
    ///       prev category works fine.
    final previousCategory = _getCategory(_activeCategory, delta: -1);
    final previousCategoryWidth =
        _getCategoryMagicData(previousCategory)?.widgetWidth;

    if (previousCategoryWidth == null) return;

    setState(() {
      _bounds = (
        // Omitting DEFAULT_SPACING since ONLY using previous category width (adding default spacing allows small over scrolling)
        lowerBoundOffset: _xOffset - previousCategoryWidth,
        // Get current offset and add prev category width to limit user scrolling to the offset + width of it
        upperBoundOffset: _xOffset + previousCategoryWidth + DEFAULT_SPACING
      );
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_bounds == null) return;

    // Derive update to the next offset by adding current offset with the delta dx dragged
    final currentBound = _xOffset + details.delta.dx;

    setState(() {
      /// NOTE: Check if the update to the offset is whin the bounds set in _onHorizontalDragStart.
      ///       Update offset only within the bound in order to prevent overscroll.
      ///
      ///       These bounds are derived based on previous category, which is a quick way to assign a
      ///       maximum width that user can scroll. COuld get both prev & next category width but the
      ///       prev category works fine.
      if (currentBound <= _bounds!.upperBoundOffset &&
          currentBound >= _bounds!.lowerBoundOffset) {
        _xOffset = currentBound;
        // Setting this state to true in order to prevent one off clicks causing trigger of
        // _onHorizontalDragEnd where the nextActiveCategory is derived and animated to.
        _isDragged = true;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails _) {
    // Prevent logic if _isDragged is false so that next active category is not derived.
    if (_bounds == null || !_isDragged) return;

    /// NOTE: Basically need to derive next category based on how far user has dragged by
    ///       calculating if the absolute of offset is larger than the absolute of the bound difference.
    ///
    ///       If offset is larger than bound difference, user scrolled to left which should show next category.
    ///       Otherwise, user has scrolled right which should show previous category.
    final boundDifference =
        (_bounds!.upperBoundOffset - _bounds!.lowerBoundOffset) / 2;
    final nextActiveCategory = _getCategory(
      _activeCategory,
      delta: _xOffset.abs() > boundDifference.abs() ? 1 : -1,
    );
    _animateToCategory(nextActiveCategory, updateSelectedCategory: true);
  }

  @override
  Widget build(BuildContext context) {
    /// NOTE: Computation of the list of categories is computationally involved so
    ///       using memo to reduce change to the result only when _activeCategory state changes
    final categories = _memoizedCategories();
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Transform.translate(
              offset: Offset(_xOffset.roundToDouble(), 0),
              child: Row(
                spacing: 8,
                children: categories,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
