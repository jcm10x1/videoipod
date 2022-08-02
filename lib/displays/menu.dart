import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/displays/agora_display.dart';
import 'package:videoipod/models/controls.dart';

import '../home_screen.dart';

class MenuDisplay extends ConsumerWidget {
  const MenuDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController controller = ScrollController();
    ref.read(controlsProvider).scrollController = controller;
    //TODO pause any content once out of view
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: ListView(
        controller: controller,
        children: [
          const MenuChoice(title: "Video Call", display: AgoraDisplay()),
        ],
      ),
    );
  }
}

class MenuChoice extends ConsumerStatefulWidget {
  final String title;
  final Widget display;
  const MenuChoice({
    required this.title,
    required this.display,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuChoice1State();
}

class _MenuChoice1State extends ConsumerState<MenuChoice> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(activeDisplay.state).state = widget.display;
      },
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
