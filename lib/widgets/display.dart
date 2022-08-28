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

class ScrollableDisplay extends ConsumerStatefulWidget {
  final List<Widget> children;
  final Widget overlay;
  const ScrollableDisplay({
    Key? key,
    required this.children,
    required this.overlay,
  }) : super(key: key);

  @override
  ScrollableDisplayState createState() => ScrollableDisplayState();
}

class ScrollableDisplayState extends ConsumerState<ScrollableDisplay> {
  final PageController _controller = PageController(viewportFraction: .6);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double page = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(controlsProvider.notifier).setScrollController(_controller);
    });
    _controller.addListener(() {
      setState(() {
        page = _controller.page!;
      });
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
              itemCount: widget.children.length,
              itemBuilder: (context, int currentIndex) {
                final relativePosition = currentIndex - page;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .003)
                    ..scale((1 - relativePosition.abs()).clamp(.2, .6) + .4)
                    ..rotateY(relativePosition),
                  alignment: relativePosition >= 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: widget.children[currentIndex],
                );
              },
            ),
            widget.overlay,
          ],
        ),
      ),
    );
  }
}