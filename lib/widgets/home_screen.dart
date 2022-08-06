import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/widgets/display_widget.dart';
import 'package:videoipod/widgets/controls_widget.dart';
import 'package:videoipod/widgets/touch_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget currentDisplay = ref.watch(activeDisplay.state).state;
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DisplayWidget(),
              const SizedBox(height: 40),
              TouchBarWidget(),
              const SizedBox(height: 40),
              const ControlsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
