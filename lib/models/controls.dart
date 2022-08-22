// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/active_display.dart';

@immutable
class Controls {
  final bool isPaused;
  final ScrollController? scrollController;
  late final VoidCallback centerPressed;
  final VoidCallback menuAction;
  late final VoidCallback pausePlayAction;
  late final VoidCallback forwardAction;
  late final VoidCallback backAction;

  Controls({
    required this.menuAction,
    this.scrollController,
    this.isPaused = false,
    VoidCallback? backAction,
    VoidCallback? centerPressed,
    VoidCallback? forwardAction,
    VoidCallback? pausePlayAction,
  }) {
    this.backAction = backAction ?? () {};
    this.centerPressed = centerPressed ?? () {};
    this.forwardAction = forwardAction ?? () {};
    this.pausePlayAction = pausePlayAction ?? () {};
  }

  Controls copyWith({
    bool? isPaused,
    ScrollController? scrollController,
    VoidCallback? centerPressed,
    VoidCallback? menuAction,
    VoidCallback? pausePlayAction,
    VoidCallback? forwardAction,
    VoidCallback? backAction,
  }) {
    return Controls(
      isPaused: isPaused ?? this.isPaused,
      scrollController: scrollController ?? this.scrollController,
      centerPressed: centerPressed ?? this.centerPressed,
      menuAction: menuAction ?? this.menuAction,
      pausePlayAction: pausePlayAction ?? this.pausePlayAction,
      forwardAction: forwardAction ?? this.forwardAction,
      backAction: backAction ?? this.backAction,
    );
  }
}

class ControlsNotifier extends StateNotifier<Controls> {
  ControlsNotifier({
    required Function() menuAction,
  }) : super(Controls(
          menuAction: menuAction,
        ));

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void setScrollController(ScrollController controller) {
    state = state.copyWith(scrollController: controller);
  }

  panHandler(DragUpdateDetails details, num radius) {
    //Pan location on wheel
    bool onTop = details.localPosition.dy <= radius;
    bool onLeft = details.localPosition.dx <= radius;
    bool onBottom = !onTop;
    bool onRight = !onLeft;

    //Pan movements
    bool panUp = details.delta.dy <= 0;
    bool panLeft = details.delta.dx <= 0;
    bool panDown = !panUp;
    bool panRight = !panLeft;

    //Absolute change on axis
    double yChange = details.delta.dy.abs();
    double xChange = details.delta.dx.abs();

    //Directional change on wheel
    double verticalRotation =
        (onRight && panDown) || (onLeft && panUp) ? yChange : yChange * -1;

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

    //Total computed change
    double rotationalChange = (verticalRotation + horizontalRotation) *
        (details.delta.distance * 0.2);

    //Move the page view scroller
    state.scrollController
        ?.jumpTo(state.scrollController!.offset + rotationalChange);
  }
}

final controlsProvider =
    StateNotifierProvider<ControlsNotifier, Controls>((ref) {
  return ControlsNotifier(
    menuAction: () {
      ref.read(activeDisplayProvider.state).state = DisplayOptions.menu;
    },
  );
});

//TODO move the highlighted menu item instead of scroll AND change the item background color