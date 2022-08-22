import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DisplayOptions {
  agoraForm,
  agoraCall,
  menu,
  youtubeViewer,
  loading,
  error,
}

final activeDisplayProvider = StateProvider<DisplayOptions>((ref) {
  return DisplayOptions.menu;
});
