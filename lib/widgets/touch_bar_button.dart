import 'package:flutter/material.dart';

class TouchBarButton extends StatelessWidget {
  const TouchBarButton({
    Key? key,
    required this.onPressed,
    this.backgroundColor = Colors.grey,
    required this.child,
  }) : super(key: key);

  final Function() onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: RawMaterialButton(
        onPressed: onPressed,
        splashColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        fillColor: backgroundColor,
        child: child,
      ),
    );
  }
}
