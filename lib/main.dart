import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      builder: (BuildContext context) {
        return ProviderScope(
          child: PlatformApp(
            material: (context, platform) => MaterialAppData(
              theme: ThemeData.light(),
            ),
            cupertino: (context, platform) => CupertinoAppData(
              theme: const CupertinoThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.black,
              ),
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
