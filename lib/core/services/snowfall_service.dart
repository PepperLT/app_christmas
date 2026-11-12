import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnowfallService extends GetxService {
  SnowfallService({SharedPreferences? preferences})
    : _preferences = preferences,
      enabled = (preferences?.getBool('snowfall_enabled') ?? true).obs;

  final SharedPreferences? _preferences;
  final RxBool enabled;
  final saving = false.obs;

  Future<void> setEnabled(bool value) async {
    if (saving.value || value == enabled.value) return;
    saving.value = true;
    try {
      final saved = await _preferences?.setBool('snowfall_enabled', value);
      if (saved == false) throw StateError('Could not save snowfall setting');
      enabled.value = value;
    } finally {
      saving.value = false;
    }
  }
}
