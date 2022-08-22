import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/widgets/display_root.dart';

import '../../display.dart';

class AgoraFormDisplay extends ConsumerWidget {
  AgoraFormDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(agoraEngineProvider);
    final engineNotifier = ref.read(agoraEngineProvider.notifier);
    final controller = TextEditingController();
    controller.text = engineNotifier.channelId ?? "";
    return Display(
      child: Column(
        children: [
          Text("Enter the call code below or tap generate"),
          PlatformTextField(
            controller: controller,
            onChanged: (value) {
              engineNotifier.setChannelId(value);
            },
          ),
        ],
      ),
    );
  }
}
