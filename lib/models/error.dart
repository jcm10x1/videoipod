import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Failure {
  final String message;
  final Function()? retry;
  const Failure({
    required this.message,
    this.retry,
  });

  @override
  String toString() => message;
}

final failureProvider = StateProvider<Failure>((ref) {
  return const Failure(message: "ERROR");
});
