import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/active_display.dart';
import 'package:videoipod/widgets/ipod_displays/agora/agora_call_display.dart';
import 'package:videoipod/widgets/ipod_displays/error_display.dart';
import 'package:videoipod/widgets/ipod_displays/menu.dart';

import 'display.dart';
import 'ipod_displays/agora/agora_form.dart';

class DisplayRoot extends ConsumerWidget {
  const DisplayRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DisplayOptions currentDisplay = ref.watch(activeDisplayProvider);
    final Widget child;
    switch (currentDisplay) {
      case DisplayOptions.loading:
        child = const Display(
          child: CircularProgressIndicator.adaptive(
            backgroundColor: Colors.black,
          ),
        );
        break;
      case DisplayOptions.agoraForm:
        child = AgoraFormDisplay();
        break;
      case DisplayOptions.agoraCall:
        child = const AgoraCallDisplay();
        break;
      case DisplayOptions.error:
        child = const ErrorDisplay();
        break;
      default:
        child = const MenuDisplay();
    }
    return child;
  }
}
