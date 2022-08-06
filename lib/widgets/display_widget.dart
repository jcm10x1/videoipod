import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ipod_displays/menu.dart';

final activeDisplay = StateProvider<Widget>((ref) => const MenuDisplay());

class DisplayWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget currentDisplay = ref.watch(activeDisplay.state).state;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints.expand(),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 0),
        ),
        child: currentDisplay,
      ),
    );
  }
}
