import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/models/touch_bar.dart';
import 'package:videoipod/widgets/ipod_displays/menu.dart';

import '../display_widget.dart';

class AgoraDisplay extends ConsumerWidget {
  const AgoraDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(agoraEngineProvider.notifier);
    final touchBar = ref.read(touchBarProvider.notifier);
    engine.setChannelId("test");
    touchBar.clear();
    touchBar.addAll([
      RoundButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          await engine.toggleMute();
          touchBar.replace(
            0,
            RoundButton(
              backgroundColor: Colors.white,
              onPressed: engine.toggleMute,
              icon: Icon(engine.isMuted ? Icons.mic : Icons.mic_off),
            ),
          );
        },
        icon: Icon(engine.isMuted ? Icons.mic : Icons.mic_off),
      ),
      RoundButton(
        onPressed: () async {
          await engine.leaveCall();
          touchBar.clear();
          ref.read(activeDisplay.state).state = const MenuDisplay();
        },
        backgroundColor: Colors.red,
        icon: const Icon(
          Icons.call_end,
          color: Colors.white,
        ),
      ),
    ]);
    return FutureBuilder(
        future: engine.joinCall(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width * .2,
                    child: (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.android)
                        ? rtc_local_view.SurfaceView(
                            channelId: engine.channelId,
                          )
                        : rtc_local_view.TextureView(
                            channelId: engine.channelId,
                          ),
                  ),
                ),
                engine.users.isNotEmpty //&& engine.errorMessage == null
                    ? Row(
                        children: engine.users
                            .map((user) =>
                                (defaultTargetPlatform == TargetPlatform.iOS ||
                                        defaultTargetPlatform ==
                                            TargetPlatform.android)
                                    ? rtc_remote_view.SurfaceView(
                                        uid: user,
                                        channelId: engine.channelId!,
                                      )
                                    : rtc_remote_view.TextureView(
                                        channelId: engine.channelId!,
                                        uid: user,
                                      ))
                            .toList(),
                      )
                    : Text(engine.errorMessage ??
                        "You are the only one on this call."),
              ],
            );
          }
          return const CircularProgressIndicator();
        });
  }
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
  }) : super(key: key);

  final Function() onPressed;
  final Color backgroundColor;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: CircleBorder(),
      fillColor: backgroundColor,
      child: icon,
    );
  }
}
//TODO Set enum for button size (small and large), pass in as optional contructor param, if present override widget size to small or large size (30 or 50)