part of controls_page;

class ControlsPage extends StatefulWidget {
  final AnimationController parentController;
  final void Function({bool? fastClose}) closeOverlayHandler;

  const ControlsPage({
    super.key,
    required this.closeOverlayHandler,
    required this.parentController,
  });

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

enum ActiveControlEnum {
  rewind,
  volumeUp,
  fastForward,
  volumeDown,
  playPause,
  none,
}

class _ControlsPageState extends State<ControlsPage>
    with TickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  late final AnimationController _3dPlaneAnimationController;

  /// Property responsible for tracking if Overlay
  /// is animating its closing state effect
  bool _isOverlayPortalAnimatingCloseEffect = false;

  /// Property responsible for tracking how many pixels user moved
  /// across the y-axis when fine tuning volume level.
  /// It is used for enabling dead zone between delta Y change and volume increment
  double _yAxisDeltaAccumulator = 0;

  double xRotation = 0; // Rotation around X-axis
  double yRotation = 0; // Rotation around Y-axis

  ActiveControlEnum isActive = ActiveControlEnum.none;

  final Debouncer _autoCloseDebouncer = Debouncer(
    duration: const Duration(seconds: 2),
    // debugName: "auto-close",
    logger: console,
  );
  final Debouncer _longPressDebouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
    logger: console,
    // debugName: "long-press",
  );
  final Repeater _longPressRepeater = Repeater(
    duration: const Duration(milliseconds: 100),
    logger: console,
    // debugName: "long-press",
  );

  /// Properties responsible for performing animation during opening of
  /// controls page. It is being driven by _expandAnimationController,
  /// separate from the rest of the control's plane.
  late final AnimationController _expandAnimationController;
  late final Animation<double> _expandAnimationVolume;
  late final Animation<double> _expandAnimationPrevNext;

  @override
  void initState() {
    super.initState();

    _3dPlaneAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _queueOverlayClosingEffect();

    /// Block responsible for animating controls on mount
    _expandAnimationVolume = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _expandAnimationController,
        curve: Curves.linear,
      ),
    );
    _expandAnimationPrevNext = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _expandAnimationController,
        curve: Curves.linear,
      ),
    );
    _expandAnimationController.forward();
  }

  @override
  void dispose() {
    _autoCloseDebouncer.cancel();
    _longPressDebouncer.cancel();
    _longPressRepeater.cancel();
    _expandAnimationController.dispose();
    _3dPlaneAnimationController.dispose();
    super.dispose();
  }

  /// Method responsible for queueing Overlay's closing effect
  /// 1. If _isOverlayPortalAnimatingCloseEffect set to true,
  ///    trigger closeOverlayHandler to cancel animation effect and set flag to false.
  /// 2. Otherwise, debounce last closeOverlayHandler call to reset auto close effect
  ///    and set flag to true to allow canceling of effect in 1st clause.
  void _queueOverlayClosingEffect() {
    if (_isOverlayPortalAnimatingCloseEffect) {
      console.log("Cancelling Overlay closing effect");

      widget.closeOverlayHandler();
      _isOverlayPortalAnimatingCloseEffect = false;
    }
    {
      _autoCloseDebouncer.call(() {
        console.log("Closing Overlay effect running");
        _isOverlayPortalAnimatingCloseEffect = true;
        widget.closeOverlayHandler();
      });
    }
  }

  void _restoreTilt() {
    _longPressDebouncer.cancel();
    _longPressRepeater.cancel();
    _3dPlaneAnimationController.stop();

    // Animate back to original position (0 degrees)
    final Animation<double> animationX =
        Tween<double>(begin: xRotation, end: 0).animate(CurvedAnimation(
      parent: _3dPlaneAnimationController,
      curve: Curves.easeInOut,
    ));

    final Animation<double> animationY =
        Tween<double>(begin: yRotation, end: 0).animate(CurvedAnimation(
      parent: _3dPlaneAnimationController,
      curve: Curves.easeInOut,
    ));

    void listener() {
      // console.log("Triggering Listener ${animationX.value} ${animationY.value}");
      setState(() {
        xRotation = animationX.value;
        yRotation = animationY.value;
      });
    }

    void statusListener(status) {
      if (status == AnimationStatus.completed) {
        if (isActive != ActiveControlEnum.none) {
          isActive = ActiveControlEnum.none;
        }
        // console.log("Unmount of listeners");
        _3dPlaneAnimationController.removeListener(listener);
        _3dPlaneAnimationController.removeStatusListener(statusListener);

        /// NOTE: The reset is done last, so that the listeners above would not
        ///       run state change on x/yRotation values.
        /// TODO: On refactor can be done is on line 203, where forward is called,
        ///       the .then((_) {...}) can reset and remove listeners mentioned above.
        _3dPlaneAnimationController.reset();
      }
    }

    // Update the state during animation frames
    _3dPlaneAnimationController.addListener(listener);
    // Reset the controller when done
    _3dPlaneAnimationController.addStatusListener(statusListener);

    // console.log("Triggering Restore");

    // Start the animation
    _3dPlaneAnimationController.forward();
  }

  void _updateRotation(DragUpdateDetails details, Size screenSize,
      {List<({ActiveControlEnum control, GlobalKey key})> widgets = const []}) {
    _queueOverlayClosingEffect();

    // console.log("Previous in ${isActive}");

    final perX = details.globalPosition.dx / screenSize.width;
    final perY = details.globalPosition.dy / screenSize.height;
    final topX = perX > .5 ? -1 : 1;
    final topY = perY > .5 ? 1 : -1;

    if (widgets.isNotEmpty) {
      for (var widget in widgets) {
        final renderBox =
            widget.key.currentContext?.findRenderObject() as RenderBox?;

        if (renderBox != null) {
          // Get the global position of the widget
          final widgetPosition = renderBox.localToGlobal(Offset.zero);
          final widgetSize = renderBox.size;

          // Define the bounds of the widget
          final Rect widgetBounds = Rect.fromLTWH(widgetPosition.dx,
              widgetPosition.dy, widgetSize.width, widgetSize.height);

          if (widgetBounds.contains(details.globalPosition)) {
            console.log("Inbound in ${widget.control}");

            setState(() {
              switch (widget.control) {
                case ActiveControlEnum.volumeDown:
                case ActiveControlEnum.volumeUp:
                  {
                    if (isActive != widget.control) {
                      _longPressRepeater.repeat(
                          () => changeVolumeLevel(control: widget.control));
                    }
                  }
                default:
              }
              isActive = widget.control;
            });
            return;
          } else {
            //
            setState(() {
              isActive = ActiveControlEnum.none;
              _longPressRepeater.cancel();
            });
          }
        }
      }
    }

    setState(() {
      isActive = ActiveControlEnum.none;
      final double deltaY = details.delta.dy;
      final double deltaX = details.delta.dx;
      // Use delta change in the dx/dy direction times 0.2 for sensitivity
      xRotation = xRotation + 0.2 * deltaY;
      yRotation = yRotation + 0.2 * -deltaX;

      /**
       * |-q1-|-q2-|
       * |-q3-|-q4-|
       */

      if (topY == -1) {
        xRotation = xRotation.clamp(-15.0, 0);
      } else {
        xRotation = xRotation.clamp(0, 15.0);
      }

      if (topX == -1) {
        yRotation = yRotation.clamp(-15.0, 0);
      } else {
        yRotation = yRotation.clamp(0, 15.0);
      }

      // This code is responsible for granular change of volume level when user pans on control pane
      // Check absolute delta Y value is 1, meaning there was a vertical drag
      // If change is over 70 steps long, perform volume change and reset the dead zone variable of _yAxisDeltaAccumulator
      if (deltaY.abs() == 1 && deltaX.abs() == 0) {
        //console.log("deltaY: ${details.delta.dy} acc: $_yAxisDeltaAccumulator");

        if (_yAxisDeltaAccumulator.abs() > 70) {
          _yAxisDeltaAccumulator = 0;

          changeVolumeLevel(change: -deltaY.ceil());
        }
        _yAxisDeltaAccumulator += deltaY;
      }
    });
  }

  void _tiltOnTap(TapDownDetails details, Size screenSize,
      {ActiveControlEnum? dir}) {
    // console.log("Triggering ${dir ?? "parent"} event");
    final perX = details.globalPosition.dx / screenSize.width;
    final perY = details.globalPosition.dy / screenSize.height;
    final topX = perX > .5 ? -1 : 1;
    final topY = perY > .5 ? 1 : -1;
    final deltaX = (perX - 0.5).abs();
    final deltaY = (perY - 0.5).abs();
    _queueOverlayClosingEffect();

    setState(() {
      if (dir != null) {
        isActive = dir;
      }
      switch (dir) {
        case ActiveControlEnum.fastForward:
        case ActiveControlEnum.rewind:
          {
            yRotation = yRotation + 0.5 * 100 * topX;
            changeSong(control: dir);
          }
        case ActiveControlEnum.volumeUp:
        case ActiveControlEnum.volumeDown:
          {
            xRotation = xRotation + 0.5 * 100 * topY;
            // Executes on tap volume change
            changeVolumeLevel(control: dir);
            // After delay specified above
            // Executes repeater which increases volume with the same delta
            // Cancelled when _restoreTilt is called on onTapUp event handler
            _longPressDebouncer.call(
              () => _longPressRepeater
                  .repeat(() => changeVolumeLevel(control: dir)),
            );
          }
        default:
          {
            xRotation = xRotation + deltaY * 100 * topY;
            yRotation = yRotation + deltaX * 100 * topX;
          }
      }

      xRotation = xRotation.clamp(-15.0, 15.0);
      yRotation = yRotation.clamp(-10.0, 10.0);
    });
  }

  void changeVolumeLevel({ActiveControlEnum? control, int? change}) {
    final globalState = context.read<GlobalModalState>();
    _queueOverlayClosingEffect();

    if (change != null) {
      globalState.changeVolumeLevel(change);
      return;
    }

    switch (control) {
      case ActiveControlEnum.volumeUp:
      case ActiveControlEnum.volumeDown:
        {
          // console.log("CHanging Volume");
          globalState.changeVolumeLevel(
              control == ActiveControlEnum.volumeUp ? 1 : -1);
          return;
        }
      default:
        return;
    }
  }

  void changeSong({ActiveControlEnum? control, int? change}) {
    final globalState = context.read<GlobalModalState>();
    _queueOverlayClosingEffect();

    if (change != null) {
      globalState.playNextPrevSong(change);
      return;
    }

    switch (control) {
      case ActiveControlEnum.rewind:
      case ActiveControlEnum.fastForward:
        {
          globalState.playNextPrevSong(
              control == ActiveControlEnum.fastForward ? 1 : -1);
          return;
        }
      default:
        return;
    }
  }

  void playPauseSong() {
    final globalState = context.read<GlobalModalState>();
    _queueOverlayClosingEffect();

    PlayPauseTrackAtPath(
      action: globalState.isPlaying
          ? PlayPauseRustActionEnum.pauseAction.value
          : PlayPauseRustActionEnum.resumeAction.value,
    ).sendSignalToRust();
    globalState.updateIsPlaying(!globalState.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final GlobalKey upVolumeKey = GlobalKey();
    final GlobalKey downVolumeKey = GlobalKey();
    final GlobalKey rewindKey = GlobalKey();
    final GlobalKey fastForwardKey = GlobalKey();
    final GlobalKey playPauseKey = GlobalKey();

    return AnimatedBuilder(
      /// NOTE: _expandAnimationController is used here instead of_3dPlaneAnimationController
      ///       because it is the controllers that renders Transform.translate animation.
      /// Another option is to merge controllers, but since the of_3dPlaneAnimationController
      /// subscribers are only using it to derive values it is not necessary.
      /// E.g
      /// animation: Listenable.merge([_expandAnimationController, _3dPlaneAnimationController]),
      /// JK I just added widget.parentController to hook into overlay hide functionality
      animation: Listenable.merge(
        [
          widget.parentController,
          _expandAnimationController,
        ],
      ),
      builder: (context, child) => GestureDetector(
        onPanUpdate: (e) => _updateRotation(e, screenSize, widgets: [
          (key: upVolumeKey, control: ActiveControlEnum.volumeUp),
          (key: downVolumeKey, control: ActiveControlEnum.volumeDown),
          (key: rewindKey, control: ActiveControlEnum.rewind),
          (key: fastForwardKey, control: ActiveControlEnum.fastForward),
          (key: playPauseKey, control: ActiveControlEnum.playPause),
        ]),
        onPanEnd: (e) => _restoreTilt(),
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: (e) => _tiltOnTap(e, screenSize),
              onTapUp: (e) => _restoreTilt(),
              child: const Backdrop(),
            ),
            const VolumeLabel(
              topPosition: 40,
              leftPosition: 0,
            ),
            GestureDetector(
              // Account for container's padding when doing test detection
              behavior: HitTestBehavior.translucent,
              onTap: () => widget.closeOverlayHandler(fastClose: true),
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 64,
                height: 64,
                child: Text(
                  "exit".toUpperCase(),
                  style: Styles.exitLabel,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                // Align exit to left of the display
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 44,
                  ),
                  Expanded(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(xRotation * pi / 180)
                        ..rotateY(yRotation * pi / 180),
                      child: Transform.scale(
                        scale: Tween<double>(begin: 1, end: 0.95)
                            .animate(
                              CurvedAnimation(
                                parent: widget.parentController,
                                curve: Curves.easeInExpo,
                              ),
                            )
                            .value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Transform.translate(
                                  offset: Offset(
                                    0,
                                    _expandAnimationVolume.value,
                                  ),
                                  child: VolumeControl(
                                    key: upVolumeKey,
                                    type: VolumeControlTypeEnum.up,
                                    onTapDown: (e, {key}) => _tiltOnTap(
                                      e,
                                      screenSize,
                                      dir: ActiveControlEnum.volumeUp,
                                    ),
                                    onTapUp: (_) => _restoreTilt(),
                                    isActive:
                                        ActiveControlEnum.volumeUp == isActive,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Transform.translate(
                                  offset:
                                      Offset(_expandAnimationPrevNext.value, 0),
                                  child: PlaybackControl(
                                    key: rewindKey,
                                    type: PlaybackControlTypeEnum.rewind,
                                    onTapDown: (e) => _tiltOnTap(e, screenSize,
                                        dir: ActiveControlEnum.rewind),
                                    onTapUp: (_) => _restoreTilt(),
                                    isActive:
                                        isActive == ActiveControlEnum.rewind,
                                  ),
                                ),
                                PlayPauseControl(
                                  key: playPauseKey,
                                  onTap: () => playPauseSong(),
                                  isActive:
                                      isActive == ActiveControlEnum.playPause,
                                ),
                                Transform.translate(
                                  offset: Offset(
                                      -_expandAnimationPrevNext.value, 0),
                                  child: PlaybackControl(
                                    key: fastForwardKey,
                                    type: PlaybackControlTypeEnum.fastForward,
                                    onTapDown: (e) => _tiltOnTap(e, screenSize,
                                        dir: ActiveControlEnum.fastForward),
                                    onTapUp: (_) => _restoreTilt(),
                                    isActive: isActive ==
                                        ActiveControlEnum.fastForward,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Transform.translate(
                                  offset:
                                      Offset(0, -_expandAnimationVolume.value),
                                  child: VolumeControl(
                                    key: downVolumeKey,
                                    hasVolumeLabel: true,
                                    type: VolumeControlTypeEnum.down,
                                    onTapDown: (e, {key}) => _tiltOnTap(
                                      e,
                                      screenSize,
                                      dir: ActiveControlEnum.volumeDown,
                                    ),
                                    onTapUp: (_) => _restoreTilt(),
                                    isActive: ActiveControlEnum.volumeDown ==
                                        isActive,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const CurrentlyPlayingLabel()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
