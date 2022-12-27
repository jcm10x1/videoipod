import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod/riverpod.dart';
import 'package:videoipod/models/user.dart';

@immutable
class AgoraSystem {
  final String channel;
  final List<User> users;
  final bool muted;
  final RtcEngine? engine;
  final int height;
  final int width;
  AgoraSystem({
    this.channel = "",
    this.users = const [],
    this.muted = false,
    this.engine,
    this.height = 50,
    this.width = 50,
  });
  final VideoEncoderConfiguration _configuration = VideoEncoderConfiguration();

  AgoraSystem copyWith({
    String? channel,
    List<User>? users,
    bool? muted,
    RtcEngine? engine,
    int? height,
    int? width,
  }) {
    return AgoraSystem(
      channel: channel ?? this.channel,
      users: users ?? this.users,
      muted: muted ?? this.muted,
      engine: engine ?? this.engine,
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }

  @override
  String toString() {
    return 'AgoraSystem(_channel: $channel, _muted: $muted, _engine: $engine, _height: $height, _width: $width)';
  }

  @override
  bool operator ==(covariant AgoraSystem other) {
    if (identical(this, other)) return true;

    return other.channel == channel &&
        other.muted == muted &&
        other.engine == engine &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return channel.hashCode ^
        muted.hashCode ^
        engine.hashCode ^
        height.hashCode ^
        width.hashCode;
  }
}

class AgoraEngineNotifier extends StateNotifier<AgoraSystem> {
  AgoraEngineNotifier() : super(AgoraSystem());

  var dio = Dio();

  // @override
  // void dispose() {
  //   state.engine?.leaveChannel();
  //   state.engine?.destroy();
  //   super.dispose();
  // }

  Future<void> _dispose() async {
    await state.engine?.leaveChannel();
    await state.engine?.destroy();
    state = AgoraSystem();
  }

  void setDimensions(VideoDimensions dimensions) {
    state._configuration.dimensions = dimensions;
  }

  void _addAgoraEventHandlers() {
    if (state.engine == null) {
      return log(
          "No Agora engine exists yet. Failed to call _addAgoraEventHandlers().");
    }
    state.engine!.setEventHandler(
      //TODO correct handlers to use copywith instead of setting new variable values.
      RtcEngineEventHandler(
        error: (code) {},
        warning: (code) {},
        joinChannelSuccess: (channel, uid, elapsed) {},
        connectionStateChanged: (connectionState, reason) {
          if (reason == ConnectionChangedReason.JoinSuccess) {
            state = state.copyWith();
          }
        },
        leaveChannel: (stats) {
          state.users.clear();
        },
        userJoined: (uid, elapsed) async {
          final UserInfo status = await state.engine!.getUserInfoByUid(uid);
          final newUser = User(name: "", uid: uid, status: "");
          state = state.copyWith(users: [...state.users, newUser]);
        },
        userOffline: (uid, reason) {
          final offlineUser =
              state.users.firstWhere((element) => element.uid == uid);
          state.users.remove(offlineUser);
          state = state.copyWith(users: [...state.users]);
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {},
        connectionLost: () {},
      ),
    );
  }

  Future<void> switchCamera() async {
    await state.engine?.switchCamera();
  }

  Future<String> _refreshAppId() async {
    final response = await dio.get(
      "http://192.168.4.103:8080/app_id",
    );
    return response.data["app_id"];
  }

  Future<String> _refreshToken() async {
    final response = await dio.get(
      "http://192.168.4.103:8080/access_token",
      queryParameters: {
        'channel_name': state.channel,
      },
    );

    return response.data["token"];
  }

  void setChannelId(String id) {
    state = state.copyWith(channel: id);
  }

  Future<ConnectionStateType>? status() {
    if (state.engine == null) return null;
    return state.engine?.getConnectionState();
  }

  Future<void> joinCall({
    required void Function() networkErrorCallback,
    required void Function() successCallback,
    required Future<void> Function() beforePermissionRequestiOSAndroid,
    required void Function(String message) permissionErrorCallback,
  }) async {
    if (state.engine == null) {
      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          if (await Permission.camera.status.isDenied ||
              await Permission.microphone.status.isDenied) {
            await beforePermissionRequestiOSAndroid();
          }
        }
        final camStatus = await Permission.camera.request();
        if (camStatus.isDenied) {
          return permissionErrorCallback(
              "Camera access is required for for video calls");
        }
        final micStatus = await Permission.microphone.request();
        if (micStatus.isDenied) {
          return permissionErrorCallback("Mic is accessed for video calls");
        }

        final newEngine = await RtcEngine.create(await _refreshAppId());
        state = state.copyWith(engine: newEngine);
        await state.engine!.enableVideo();
        await state.engine!.setChannelProfile(ChannelProfile.Communication);
        _addAgoraEventHandlers();

        if (state.width == 50 && state.height == 50) {
          log("call setDimensions method. Will use default values.");
        }
        await state.engine!.setVideoEncoderConfiguration(state._configuration);
        await state.engine
            ?.joinChannel(await _refreshToken(), state.channel, null, 0);
      } on DioError catch (e) {
        switch (e.type) {
          case DioErrorType.connectTimeout:
            networkErrorCallback();
            return;
          default:
            networkErrorCallback();
            print(e.error);
            return;
        }
      }
      successCallback();
    }
  }

  Stream listenUserStatus() async* {}

  Future<void> leaveCall() async {
    await _dispose();
  }

  Future<void> toggleMute() async {
    await state.engine?.muteLocalAudioStream(!state.muted);
    state = state.copyWith(muted: !state.muted);
  }

  List<User> get users => List.unmodifiable(state.users);
  String? get channelId => state.channel;
  bool get isMuted => state.muted;
}

final agoraEngineProvider =
    StateNotifierProvider<AgoraEngineNotifier, dynamic>((ref) {
  return AgoraEngineNotifier();
});
