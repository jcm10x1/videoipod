import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:riverpod/riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class AgoraSystem {
  String? _channel;
  final List<int> _users = [];
  bool _muted = false;
  final List<String> infoStrings = [];
  RtcEngine? _engine;
  int? _height;
  int? _width;
  String? _errorMessage;
  VideoEncoderConfiguration _configuration = VideoEncoderConfiguration();

  AgoraSystem copyWith({
    String? channel,
    List<int>? users,
    bool? isMuted,
    List<String>? infoStrings,
    RtcEngine? engine,
    int? height,
    int? width,
    String? errorMessage,
    VideoEncoderConfiguration? configuration,
  }) {
    final newAgoraSystem = AgoraSystem();
    newAgoraSystem._channel = channel ?? _channel;
    newAgoraSystem._users.addAll(users ?? _users);
    newAgoraSystem._muted = isMuted ?? _muted;
    newAgoraSystem.infoStrings.addAll(infoStrings ?? this.infoStrings);
    newAgoraSystem._engine = engine ?? _engine;
    newAgoraSystem._height = height ?? _height;
    newAgoraSystem._width = width ?? _width;
    newAgoraSystem._errorMessage = errorMessage ?? _errorMessage;
    newAgoraSystem._configuration = configuration ?? _configuration;
    return newAgoraSystem;
  }
}

class AgoraEngineNotifier extends StateNotifier<AgoraSystem> {
  AgoraEngineNotifier() : super(AgoraSystem());
  final secureStorage = const FlutterSecureStorage();

  var dio = Dio();

  Future<void> initialize() async {
    await _requestPermission(Permission.camera);
    await _requestPermission(Permission.microphone);
    _refreshToken();
    await _refreshAppId();
    final String? appId = await secureStorage.read(key: "agoraAppId");
    if (appId == null) {
      return state.infoStrings
          .add("ERROR: Failed to initialize video call engine. Code Init1");
    }
    state = state.copyWith(engine: await RtcEngine.create(appId));
    if (state._engine == null) {
      return state.infoStrings
          .add("ERROR: Failed to initialize video call engine. Code Init2");
    }
    await state._engine!.enableVideo();
    await state._engine!.setChannelProfile(ChannelProfile.Communication);
    _addAgoraEventHandlers();

    if (state._width == null || state._height == null) {
      log("call setDimensions method. Will use default values.");
    }
    state.infoStrings.add("This is a bug. Please file.");
    await state._engine!.setVideoEncoderConfiguration(state._configuration);
  }

  Future<void> _dispose() async {
    await state._engine?.leaveChannel();
    await state._engine?.destroy();
    state = state.copyWith(
      users: [],
      engine: null,
    );
  }

  void setDimensions(VideoDimensions dimensions) {
    state._configuration.dimensions = dimensions;
  }

  void _addAgoraEventHandlers() {
    if (state._engine == null) {
      return log(
          "No Agora engine exists yet. Failed to call _addAgoraEventHandlers().");
    }
    state._engine!.setEventHandler(
      //TODO correct handlers to use copywith instead of setting new variable values.
      RtcEngineEventHandler(
        error: (code) {
          state._errorMessage = "Error: ${code.name}";
          state.infoStrings.add("Video Service Error: $code");
        },
        warning: (code) {
          state._errorMessage = "Warning: ${code.name}";
          state.infoStrings.add("Video Service Warning: $code");
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          state.infoStrings.add("Joimed Channel: $channel, $uid");
        },
        leaveChannel: (stats) {
          state._users.clear();
          state.infoStrings.add("User left the channel");
        },
        userJoined: (uid, elapsed) {
          state = state.copyWith(users: [...state._users, uid]);
          state.infoStrings.add("User joined: $uid");
        },
        userOffline: (uid, reason) {
          state._users.remove(uid);
          state.infoStrings.add("User $uid is offline because $reason");
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          state = state.copyWith(errorMessage: null);
          state.infoStrings.add("First remote video: $uid, $width x $height");
        },
        connectionLost: () {
          state._errorMessage =
              "ERROR: Unable to connect to the server. Please make sure you are connected to the internet.";
          state.infoStrings.add("ERROR: NO VIDEO SERVICE CONNECTION");
        },
      ),
    );
  }

  Future<bool> _refreshAppId() async {
    Response response;
    response = await dio.get(
      "http://10.0.0.4:8080/app_id",
    );
    //TODO secure storage not nessesary
    await secureStorage.write(
        key: "agoraAppId", value: response.data["app_id"]);
    //if it fails to update, add error to infoStrings and return false.
    return true;
  }

  Future<bool> _refreshToken() async {
    //get token from server

    Response response;
    response = await dio.get(
      "http://10.0.0.4:8080/access_token",
      queryParameters: {
        'channel_name': state._channel,
      },
    );
    //TODO secure storage not nessesary
    await secureStorage.write(key: "agoraToken", value: response.data["token"]);
    //if it fails to update, add error to infoStrings and return false.
    return true;
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }

  void setChannelId(String id) {
    state = state.copyWith(channel: id);
  }

  Future<void> joinCall() async {
    if (state._engine == null) {
      await initialize();

      final String? token = await secureStorage.read(key: "agoraToken");
      await state._engine!
          .joinChannel(token, state._channel ?? "unnamed", null, 0);
    }
  }

  Future<void> leaveCall() async {
    await _dispose();
  }

  Future<void> toggleMute() async {
    state._muted = !state._muted;
    await state._engine?.muteLocalAudioStream(state._muted);
  }

  List<int> get users => state._users;
  String? get channelId => state._channel;
  bool get isMuted => state._muted;
  String? get errorMessage => state._errorMessage;
}

final agoraEngineProvider =
    StateNotifierProvider<AgoraEngineNotifier, dynamic>((ref) {
  return AgoraEngineNotifier();
});
