import 'package:get/get.dart';

import '../../../music/data/music_player_service.dart';

class SettingsController extends GetxController {
  SettingsController({required MusicPlayerService musicService})
    : _musicService = musicService;

  final MusicPlayerService _musicService;

  bool get playMusic => _musicService.playMusic.value;

  void setPlayMusic(bool enabled) {
    _musicService.setPlayMusic(enabled);
  }
}
