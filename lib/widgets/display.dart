import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/controls.dart';

class Display extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  const Display(
      {Key? key, this.backgroundColor = Colors.white, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints.expand(),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: child,
      ),
    );
  }
}

class ScrollableDisplay extends ConsumerWidget {
  final List<Widget> children;
  final Widget overlay;
  ScrollableDisplay({
    Key? key,
    required this.children,
    required this.overlay,
  }) : super(key: key);

  final PageController _controller = PageController(viewportFraction: .6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(controlsProvider.notifier).setScrollController(_controller);
    });

    return Display(
      backgroundColor: Colors.black,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            PageView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: children.length,
                itemBuilder: (context, int currentIndex) {
                  // if (_controller.positions.isEmpty) {
                  //   children.add(
                  //     Container(
                  //       clipBehavior: Clip.antiAlias,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(25),
                  //       ),
                  //       child: CircularProgressIndicator.adaptive(
                  //         backgroundColor: Colors.black,
                  //       ),
                  //     ),
                  //   );
                  // }
                  final relativePosition = currentIndex - _controller.page!;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, .003)
                      ..scale((1 - relativePosition.abs()).clamp(.2, .6) + .4)
                      ..rotateY(relativePosition),
                    alignment: relativePosition >= 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: children[currentIndex],
                  );
                }),
            overlay,
          ],
        ),
      ),
    );
  }
}
