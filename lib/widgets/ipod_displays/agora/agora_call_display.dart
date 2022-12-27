import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/widgets/display.dart';
import 'package:videoipod/widgets/draggble.dart';

class AgoraCallDisplay extends ConsumerWidget {
  const AgoraCallDisplay({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineNotifier = ref.watch(agoraEngineProvider.notifier);
    ref.watch(agoraEngineProvider);
    return ScrollableDisplay(
      overlay: OurDraggable(
        height: 150,
        alignment: Alignment.bottomRight,
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        child: (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.android)
            ? rtc_local_view.SurfaceView(
                channelId: engineNotifier.channelId,
              )
            : rtc_local_view.TextureView(
                channelId: engineNotifier.channelId,
              ),
      ),
      children: engineNotifier.users.isNotEmpty //&& engine.errorMessage == null
          ? engineNotifier.users.map((user) {
              if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android) {
                return rtc_remote_view.SurfaceView(
                  uid: user.uid,
                  channelId: engineNotifier.channelId!,
                );
              } else {
                return rtc_remote_view.TextureView(
                  channelId: engineNotifier.channelId!,
                  uid: user.uid,
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
