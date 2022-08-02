import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TouchBar {
  final List<Widget> _children = [];
  TouchBar copyWith({required List<Widget> children}) {
    final newInstance = TouchBar();
    newInstance._children.addAll(children);
    return newInstance;
  }
}

class TouchBarNotifier extends StateNotifier<TouchBar> {
  TouchBarNotifier() : super(TouchBar());

  void add(Widget child) {
    state = state.copyWith(children: [...state._children, child]);
  }

  void addAll(List<Widget> children) {
    state = state.copyWith(children: [...state._children, ...children]);
  }

  void replace(int index, Widget newWidget) {
    state._children[index] = newWidget;
    state = state.copyWith(children: [...state._children]);
  }

  void clear() {
    state = state.copyWith(children: []);
  }

  List<Widget> get getChildren => state._children;
}

final touchBarProvider =
    StateNotifierProvider<TouchBarNotifier, TouchBar>((ref) {
  return TouchBarNotifier();
});
//TODO try accessing list methods with regular provider