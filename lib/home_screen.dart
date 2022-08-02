import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/controls.dart';
import 'package:videoipod/controls_widget.dart';
import 'package:videoipod/displays/menu.dart';
import 'package:videoipod/models/touch_bar.dart';
import 'package:videoipod/touch_bar_widget.dart';

final activeDisplay = StateProvider<Widget>((ref) => const MenuDisplay());

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDisplay = ref.watch(activeDisplay.state).state;
    final touchBarInstance = ref.watch(touchBarProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(width: 0),
                  ),
                  child: currentDisplay,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                color: Colors.black,
                child: Row(children: touchBarInstance.getChildren),
              ),
              const SizedBox(height: 40),
              const ControlsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
