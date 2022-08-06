import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display_widget.dart';
import '../widgets/ipod_displays/menu.dart';

class Controls {
  bool _isPaused = false;
  ScrollController? scrollController;
  Function() centerPressed = () {
    print("Center Button Preesed");
  };
  Function() menuAction;
  Function() pausePlayAction = () {
    print("Pause/Play pressed");
  };
  Function() forwardAction = () {
    print("Fast Forward pressed");
  };
  Function() backAction = () {
    print("Rewind pressed");
  };

  Controls({required this.menuAction});
}

class ControlsNotifier extends StateNotifier<Controls> {
  ControlsNotifier({required Function() menuAction})
      : super(Controls(menuAction: menuAction));

  void togglePause() {
    state._isPaused = !state._isPaused;
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

  bool get isPaused => state._isPaused;
}

final controlsProvider =
    StateNotifierProvider<ControlsNotifier, Controls>((ref) {
  return ControlsNotifier(menuAction: () {
    ref.read(activeDisplay.state).state = const MenuDisplay();
  });
});
//TODO move the highlighted menu item instead of scroll AND change the item background color