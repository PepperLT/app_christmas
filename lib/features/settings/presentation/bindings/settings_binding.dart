import 'package:get/get.dart';

import '../../../music/data/music_player_service.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(musicService: Get.find<MusicPlayerService>()),
    );
  }
}
