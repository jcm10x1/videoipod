import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/agora_engine.dart';

import '../../display.dart';

class AgoraFormDisplay extends ConsumerWidget {
  AgoraFormDisplay({Key? key}) : super(key: key);

  final controller = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineNotifier = ref.read(agoraEngineProvider.notifier);
    ref.listen(agoraEngineProvider, (dynamic previous, dynamic next) {
      final newId = ref.read(agoraEngineProvider.notifier).channelId;
      if (newId != controller.text) {
        controller.text = newId!;
      }
    });
    controller.text = engineNotifier.channelId ?? "";
    return Display(
      child: Column(
        children: [
          const Text("Enter the call code below or tap generate"),
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
