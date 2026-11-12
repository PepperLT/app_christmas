import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../premium/data/premium_service.dart';

class WallpaperService extends GetxService {
  WallpaperService({SharedPreferences? preferences})
    : _preferences = preferences {
    final saved = preferences?.getString('countdown_wallpaper');
    selectedAsset.value = assets.contains(saved) && canUse(saved!)
        ? saved
        : defaultAsset;
  }
  static const defaultAsset = 'assets/images/countdown.png';
  static final assets = List<String>.unmodifiable([
    defaultAsset,
    for (var i = 1; i <= 10; i++) 'assets/images/wallpapers/wallpapers_$i.png',
  ]);
  final SharedPreferences? _preferences;
  final selectedAsset = defaultAsset.obs;
  StreamSubscription<bool>? _premiumChanges;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PremiumService>()) {
      _premiumChanges = Get.find<PremiumService>().accessChanges.listen((_) {
        if (!canUse(selectedAsset.value)) selectedAsset.value = defaultAsset;
      });
    }
  }

  @override
  void onClose() {
    unawaited(_premiumChanges?.cancel());
    super.onClose();
  }

  static bool isPremium(String asset) =>
      assets.contains(asset) &&
      asset != defaultAsset &&
      asset != 'assets/images/wallpapers/wallpapers_1.png';
  bool canUse(String asset) => !isPremium(asset) || PremiumService.isUnlocked;

  Future<void> select(String asset) async {
    if (!assets.contains(asset)) throw ArgumentError('Unknown wallpaper');
    if (!canUse(asset)) throw const PremiumRequiredException();
    final saved = await _preferences?.setString('countdown_wallpaper', asset);
    if (saved == false) throw StateError('Could not save wallpaper');
    selectedAsset.value = asset;
  }
}
