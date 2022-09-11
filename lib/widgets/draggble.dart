import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OurDraggable extends ConsumerStatefulWidget {
  final double? boundaryHeight;
  final double? boundaryWidth;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final Widget child;
  final Alignment alignment;

  const OurDraggable({
    Key? key,
    this.boundaryHeight,
    this.boundaryWidth,
    this.height,
    this.width,
    this.aspectRatio,
    required this.child,
    this.alignment = Alignment.topLeft,
  }) : super(key: key);

  @override
  DraggablePreviewState createState() => DraggablePreviewState();
}

class DraggablePreviewState extends ConsumerState<OurDraggable> {
  late Offset _offset = const Offset(0, 0);
  late Offset _maxOffset;

  void _updateMaxOffset(double boundaryWidth, double boundaryHeight) {
    _maxOffset = Offset(
      widget.boundaryWidth ??
          boundaryWidth - (widget.height! * widget.aspectRatio!),
      widget.boundaryHeight ?? boundaryHeight - widget.height!,
    );
  }

  void _updateOffset(DragUpdateDetails dragUpdateDetails) {
    double newXOffset = _offset.dx + dragUpdateDetails.delta.dx;
    double newYOffset = _offset.dy + dragUpdateDetails.delta.dy;

    if (newXOffset < 0) {
      newXOffset = 0;
    } else if (newXOffset > _maxOffset.dx) {
      newXOffset = _maxOffset.dx;
    }

    if (newYOffset < 0) {
      newYOffset = 0;
    } else if (newYOffset > _maxOffset.dy) {
      newYOffset = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(
        newXOffset,
        newYOffset,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    const Alignment alignment = Alignment.bottomRight;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offset = alignment.alongOffset(_maxOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert((widget.height != null ||
            widget.width != null && widget.aspectRatio != null) ||
        widget.height != null && widget.width != null);
    assert(widget.height == null ||
        widget.width == null && widget.aspectRatio != null);

    return LayoutBuilder(
      builder: (context, constraints) {
        _updateMaxOffset(constraints.maxWidth, constraints.maxHeight);
        return Container(
          alignment: Alignment.topLeft,
          height: widget.boundaryHeight ?? constraints.maxHeight,
          width: widget.boundaryWidth ?? constraints.maxWidth,
          child: Transform.translate(
            offset: _offset,
            child: GestureDetector(
              onPanUpdate: _updateOffset,
              child: Container(
                clipBehavior: Clip.antiAlias,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio!,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
