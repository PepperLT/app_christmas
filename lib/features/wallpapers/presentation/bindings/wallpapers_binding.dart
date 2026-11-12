import 'package:get/get.dart';
import '../../data/wallpaper_service.dart';
import '../controllers/wallpapers_controller.dart';

class WallpapersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WallpapersController(service: Get.find<WallpaperService>()),
    );
  }
}
