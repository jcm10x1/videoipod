import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:videoipod/models/error.dart';
import 'package:videoipod/widgets/display.dart';

class ErrorDisplay extends ConsumerWidget {
  const ErrorDisplay({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Display(
      backgroundColor: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.exclamationmark_octagon_fill),
          Text(
            ref.watch(failureProvider.state).state.message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
