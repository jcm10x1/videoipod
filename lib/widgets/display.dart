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
  double page = 0;

  @override
  void initState() {
    _controller.addListener(() {
      ref.read(controlsProvider).forwardAction = () {
        _controller.nextPage(
            duration: const Duration(seconds: 5), curve: Curves.ease);
      };
      setState(() {
        page = _controller.page!;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(controlsProvider.notifier).setScrollController(_controller);
    });
    super.initState();
  }

  @override
  void dispose() {
    ref.read(controlsProvider.notifier).reset();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                return ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, .003)
                      ..scale((1 - relativePosition.abs()).clamp(.2, .6) + .4)
                      ..rotateY(relativePosition),
                    alignment: relativePosition >= 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: widget.children[currentIndex],
                  ),
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
