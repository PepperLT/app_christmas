import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperService extends GetxService {
  WallpaperService({SharedPreferences? preferences})
    : _preferences = preferences {
    final saved = preferences?.getString('countdown_wallpaper');
    selectedAsset.value = assets.contains(saved) ? saved! : defaultAsset;
  }
  static const defaultAsset = 'assets/images/countdown.png';
  static final assets = List<String>.unmodifiable([
    defaultAsset,
    for (var i = 1; i <= 10; i++) 'assets/images/wallpapers/wallpapers_$i.png',
  ]);
  final SharedPreferences? _preferences;
  final selectedAsset = defaultAsset.obs;

  Future<void> select(String asset) async {
    if (!assets.contains(asset)) throw ArgumentError('Unknown wallpaper');
    final saved = await _preferences?.setString('countdown_wallpaper', asset);
    if (saved == false) throw StateError('Could not save wallpaper');
    selectedAsset.value = asset;
  }
}
