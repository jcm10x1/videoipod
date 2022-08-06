import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/touch_bar.dart';

class TouchBarWidget extends ConsumerWidget {
  const TouchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchBarInstance = ref.watch(touchBarProvider.notifier);
    return Container(
      color: Colors.black,
      child: Row(children: touchBarInstance.getChildren),
    );
  }
}
