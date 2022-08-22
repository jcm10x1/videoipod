import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:videoipod/models/active_display.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/models/error.dart';
import 'package:videoipod/widgets/touch_bar_button.dart';

class TouchBar extends ConsumerWidget {
  const TouchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDisplay = ref.watch(activeDisplayProvider.state);
    final engineNotifier = ref.watch(agoraEngineProvider.notifier);
    final failureProviderState = ref.read(failureProvider.state);
    const uuid = Uuid();
    late final List<Widget> children;
    switch (activeDisplay.state) {
      case DisplayOptions.agoraForm:
        children = [
          TouchBarButton(
            onPressed: () async {
              if (engineNotifier.channelId == "") {
                engineNotifier.setChannelId(uuid.v4());
              }
              activeDisplay.state = DisplayOptions.loading;

              await engineNotifier.joinCall(
                successCallback: () {
                  activeDisplay.state = DisplayOptions.agoraCall;
                },
                beforePermissionRequestiOSAndroid: () {
                  return showPlatformDialog(
                      context: context,
                      builder: (context) {
                        return PlatformAlertDialog(
                          title: const Text(
                              "Will need permission for the camera and mic to use the video call feature"),
                          actions: [
                            PlatformDialogAction(
                              child: const Text("ok"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        );
                      });
                },
                permissionErrorCallback: (permission) {
                  print("permission error");
                  failureProviderState.state =
                      Failure(message: permission.toString());
                  activeDisplay.state = DisplayOptions.error;
                },
                networkErrorCallback: () {
                  print("network error");
                  failureProviderState.state = Failure(
                    message:
                        "Failed to connect to server. Check internet connection and our system status.",
                    retry: () async {
                      await engineNotifier.joinCall(
                        successCallback: () {
                          activeDisplay.state = DisplayOptions.agoraCall;
                        },
                        beforePermissionRequestiOSAndroid: () async {
                          await showPlatformDialog(
                              context: context,
                              builder: (context) {
                                return PlatformAlertDialog(
                                  title: const Text(
                                      "Will need permission for the camera and mic to use the video call feature"),
                                  actions: [
                                    PlatformDialogAction(
                                      child: const Text("ok"),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                );
                              });
                        },
                        permissionErrorCallback: (permission) {
                          failureProviderState.state =
                              Failure(message: permission.toString());
                          activeDisplay.state = DisplayOptions.error;
                        },
                        networkErrorCallback: () {
                          failureProviderState.state = Failure(
                            message:
                                "Failed to connect to server. Check internet connection and our system status.",
                            retry: () {},
                          );
                          activeDisplay.state = DisplayOptions.error;
                        },
                      );
                    },
                  );
                  activeDisplay.state = DisplayOptions.error;
                },
              );
            },
            child: const Text("Join"),
          ),
          TouchBarButton(
            onPressed: () {
              engineNotifier.setChannelId(uuid.v4());
            },
            child: const Text("Generate"),
          ),
        ];
        break;
      case DisplayOptions.agoraCall:
        ref.watch(agoraEngineProvider);
        children = [
          TouchBarButton(
            onPressed: () async {
              await engineNotifier.leaveCall();
              activeDisplay.state = DisplayOptions.menu;
            },
            backgroundColor: Colors.red,
            child: Icon(
              PlatformIcons(context).phoneSolid,
              color: Colors.white,
            ),
          ),
          TouchBarButton(
            onPressed: () async {
              await engineNotifier.toggleMute();
            },
            backgroundColor: Colors.white,
            child: Icon(
              engineNotifier.isMuted
                  ? PlatformIcons(context).micOff
                  : PlatformIcons(context).micSolid,
            ),
          ),
          TouchBarButton(
            onPressed: () {
              engineNotifier.switchCamera();
            },
            backgroundColor: Colors.white,
            child: Icon(
              PlatformIcons(context).switchCameraSolid,
            ),
          )
        ];
        break;
      case DisplayOptions.error:
        children = [
          TouchBarButton(
            onPressed: () {},
            child: const Text("Open System Status"),
          ),
        ];
        if (failureProviderState.state.retry != null) {
          children.add(TouchBarButton(
            onPressed: failureProviderState.state.retry!,
            child: const Text("Retry"),
          ));
        }
        break;
      default:
        children = [];
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
