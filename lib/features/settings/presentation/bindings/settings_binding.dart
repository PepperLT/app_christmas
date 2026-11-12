import 'package:get/get.dart';

import '../../../music/data/music_player_service.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/services/snowfall_service.dart';
import '../../../../core/services/sound_effects_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SoundEffectsService>()) {
      Get.put(SoundEffectsService(), permanent: true);
    }
    if (!Get.isRegistered<SnowfallService>()) {
      Get.put(SnowfallService(), permanent: true);
    }
    Get.lazyPut<SettingsController>(
      () => SettingsController(musicService: Get.find<MusicPlayerService>()),
    );
  }
}
