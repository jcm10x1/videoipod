import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TouchBar {
  final List<Widget> _children = [];
}

class TouchBarNotifier extends ChangeNotifier {
  final touchBarInstance = TouchBar();
  void add(Widget child) {
    touchBarInstance._children.add(child);
    notifyListeners();
  }

  void addAll(List<Widget> children) {
    touchBarInstance._children.addAll(children);
    notifyListeners();
  }

  void replace(int index, Widget newWidget) {
    touchBarInstance._children[index] = newWidget;
    notifyListeners();
  }

  void clear() {
    touchBarInstance._children.clear();
    notifyListeners();
  }

  List<Widget> get getChildren => touchBarInstance._children;
}

final touchBarProvider = ChangeNotifierProvider<TouchBarNotifier>((ref) {
  return TouchBarNotifier();
});
//TODO try accessing list methods with regular provider