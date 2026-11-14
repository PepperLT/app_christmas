import 'package:get/get.dart';

import '../../../music/music_dependencies.dart';
import '../../../../core/services/snowfall_service.dart';
import '../../../../core/services/sound_effects_service.dart';

class SettingsController extends GetxController {
  SettingsController({required MusicPlayerService musicService})
    : _musicService = musicService;

  final MusicPlayerService _musicService;
  SnowfallService get snowfall => Get.find<SnowfallService>();
  SoundEffectsService get soundEffects => Get.find<SoundEffectsService>();

  Future<void> setSoundEffects(bool enabled) async {
    try {
      await soundEffects.setEnabled(enabled);
    } catch (_) {
      Get.snackbar('Sound Effects', 'Không thể lưu cài đặt. Hãy thử lại.');
    }
  }

  Future<void> setSnowfall(bool enabled) async {
    try {
      await snowfall.setEnabled(enabled);
    } catch (_) {
      Get.snackbar('Snowfall Effect', 'Không thể lưu cài đặt. Hãy thử lại.');
    }
  }

  bool get playMusic => _musicService.playMusic.value;

  void setPlayMusic(bool enabled) {
    _musicService.setPlayMusic(enabled);
  }
}
