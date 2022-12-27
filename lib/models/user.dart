import 'package:flutter/foundation.dart';

@immutable
class User {
  final String name;
  final int uid;
  final String status;
  const User({
    required this.name,
    required this.uid,
    required this.status,
  });

  User copyWith({
    String? name,
    int? uid,
    String? status,
  }) {
    return User(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      status: status ?? this.status,
    );
  }
}
