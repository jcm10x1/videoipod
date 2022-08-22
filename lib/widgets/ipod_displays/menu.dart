import 'package:agora_rtc_engine/rtc_engine.dart' as rtc_engine;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/active_display.dart';
import 'package:videoipod/models/agora_engine.dart';
import 'package:videoipod/models/controls.dart';

import '../display.dart';

class MenuDisplay extends ConsumerWidget {
  const MenuDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(controlsProvider.notifier).setScrollController(controller);
    });

    final engine = ref.watch(agoraEngineProvider.notifier);
    final display = ref.watch(activeDisplayProvider.state);
    //TODO pause any content once out of view
    return Display(
      child: ListView(
        controller: controller,
        children: [
          MenuChoice(
            title: "Video Call",
            onTap: () async {
              final status = await engine.status();
              switch (status) {
                case rtc_engine.ConnectionStateType.Connected:
                  display.state = DisplayOptions.agoraCall;
                  break;
                case rtc_engine.ConnectionStateType.Connecting:
                  display.state = DisplayOptions.loading;
                  break;
                default:
                  display.state = DisplayOptions.agoraForm;
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

class MenuChoice extends ConsumerStatefulWidget {
  final String title;
  final Function() onTap;
  const MenuChoice({
    required this.title,
    required this.onTap,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuChoiceState();
}

class _MenuChoiceState extends ConsumerState<MenuChoice> {
  final bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: _isSelected == true ? Colors.blue : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
