import 'package:get/get.dart';
import '../../data/wallpaper_service.dart';

class WallpapersController extends GetxController {
  WallpapersController({required this.service});
  final WallpaperService service;
  final saving = false.obs;
  final error = RxnString();
  Future<bool> apply(String asset) async {
    if (saving.value) return false;
    saving.value = true;
    error.value = null;
    try {
      await service.select(asset);
      return true;
    } catch (_) {
      error.value = 'Unable to save wallpaper. Please try again.';
      return false;
    } finally {
      saving.value = false;
    }
  }
}
