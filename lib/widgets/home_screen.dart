import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/widgets/control_dial.dart';
import 'package:videoipod/widgets/display_root.dart';
import 'package:videoipod/widgets/touch_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              DisplayRoot(),
              TouchBar(),
              ControlDial(),
            ],
          ),
        ),
      ),
    );
  }
}
