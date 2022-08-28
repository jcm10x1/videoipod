import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/widgets/display.dart';

class AgoraCallDisplay extends ConsumerWidget {
  const AgoraCallDisplay({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineNotifier = ref.watch(agoraEngineProvider.notifier);

    ref.watch(agoraEngineProvider);
    return ScrollableDisplay(
      overlay: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Text(
                engineNotifier.channelId ?? "ERROR",
              ),
            ),
            DraggablePreview(
              boundaryHeight: constraints.maxHeight,
              boundaryWidth: constraints.maxWidth,
              height: 150,
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
            ),
          ],
        );
      }),
      children: engineNotifier.users.isNotEmpty //&& engine.errorMessage == null
          ? engineNotifier.users.map((user) {
              if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android) {
                return rtc_remote_view.SurfaceView(
                  uid: user,
                  channelId: engineNotifier.channelId!,
                );
              } else {
                return rtc_remote_view.TextureView(
                  channelId: engineNotifier.channelId!,
                  uid: user,
                );
              }
            }).toList()
          : [
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: const Text("You are the only one on this call."),
              ),
            ],
    );
  }
}

class DraggablePreview extends ConsumerStatefulWidget {
  final double boundaryHeight;
  final double boundaryWidth;
  final double height;
  final double aspectRatio;

  const DraggablePreview({
    Key? key,
    required this.boundaryHeight,
    required this.boundaryWidth,
    required this.height,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  DraggablePreviewState createState() => DraggablePreviewState();
}

class DraggablePreviewState extends ConsumerState<DraggablePreview> {
  late Offset _offset = const Offset(0, 0);
  late Offset _maxOffset;

  void _updateMaxOffset() {
    _maxOffset = Offset(
      widget.boundaryWidth - (widget.height * widget.aspectRatio),
      widget.boundaryHeight - widget.height,
    );
  }

  void _updateOffset(DragUpdateDetails dragUpdateDetails) {
    double newXOffset = _offset.dx - dragUpdateDetails.delta.dx;
    double newYOffset = _offset.dy - dragUpdateDetails.delta.dy;

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
    _updateMaxOffset();
  }

  @override
  Widget build(BuildContext context) {
    final AgoraEngineNotifier engineNotifier =
        ref.read(agoraEngineProvider.notifier);

    return Positioned(
        bottom: _offset.dy,
        right: _offset.dx,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            _updateOffset(dragUpdateDetails);
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            height: widget.height,
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: (defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.android)
                  ? rtc_local_view.SurfaceView(
                      channelId: engineNotifier.channelId,
                    )
                  : rtc_local_view.TextureView(
                      channelId: engineNotifier.channelId,
                    ),
            ),
          ),
        ));
  }
}
