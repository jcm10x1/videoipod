import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/controls.dart';

class ControlsWidget extends ConsumerWidget {
  const ControlsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = ref.watch(controlsProvider);
    bool isPaused = ref.watch(controlsProvider.notifier).isPaused;
    return Center(
        child: Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onPanUpdate: (details) =>
              ref.watch(controlsProvider.notifier).panHandler(details, 150),
          child: Container(
            height: 300,
            width: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30),
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: controls.menuAction,
                    child: const Text(
                      "MENU",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 30),
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.fast_forward),
                    iconSize: 40,
                    color: Colors.white38,
                    onPressed: controls.forwardAction,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 30),
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    icon: isPaused
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.pause),
                    iconSize: 40,
                    color: Colors.white38,
                    onPressed: controls.pausePlayAction,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 30),
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    iconSize: 40,
                    color: Colors.white38,
                    onPressed: controls.backAction,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: controls.centerPressed,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white38,
            ),
          ),
        ),
      ],
    ));
  }
}
