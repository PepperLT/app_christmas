import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundEffect {
  merge('assets/effects/merge_pop.wav'),
  reward('assets/effects/reward_bell.wav'),
  rescue('assets/effects/rescue_sparkle.wav');

  const SoundEffect(this.asset);
  final String asset;
}

class SoundEffectsService extends GetxService {
  SoundEffectsService({SharedPreferences? preferences, AudioPlayer? player})
    : _preferences = preferences,
      _player = player ?? AudioPlayer(),
      enabled = (preferences?.getBool('sound_effects_enabled') ?? true).obs;

  final SharedPreferences? _preferences;
  final AudioPlayer _player;
  final RxBool enabled;
  final saving = false.obs;
  bool _closed = false;
  bool _working = false;
  int _revision = 0;
  SoundEffect? _requested;

  static void emit(SoundEffect effect) {
    if (Get.isRegistered<SoundEffectsService>()) {
      Get.find<SoundEffectsService>().play(effect);
    }
  }

  Future<void> setEnabled(bool value) async {
    if (_closed || saving.value || value == enabled.value) return;
    saving.value = true;
    try {
      final saved = await _preferences?.setBool('sound_effects_enabled', value);
      if (saved == false) throw StateError('Could not save sound setting');
      if (_closed) return;
      enabled.value = value;
      if (!value) {
        _requested = null;
        _revision++;
        if (!_working) unawaited(_updatePlayback());
      }
    } finally {
      if (!_closed) saving.value = false;
    }
  }

  void play(SoundEffect effect) {
    if (_closed || !enabled.value) return;
    _requested = effect;
    _revision++;
    if (!_working) unawaited(_updatePlayback());
  }

  Future<void> _updatePlayback() async {
    _working = true;
    try {
      var applied = -1;
      while (!_closed && applied != _revision) {
        applied = _revision;
        final effect = _requested;
        try {
          await _player.stop();
          if (_closed || applied != _revision) continue;
          if (!enabled.value || effect == null) continue;
          await _player.setAsset(effect.asset);
          if (_closed || !enabled.value || applied != _revision) continue;
          unawaited(_start());
        } catch (_) {
          // A missing or unsupported sound must not interrupt gameplay.
        }
      }
    } finally {
      _working = false;
    }
  }

  Future<void> _start() async {
    try {
      await _player.play();
    } catch (_) {
      /* Best-effort sound. */
    }
  }

  @override
  void onClose() {
    _closed = true;
    _revision++;
    unawaited(_player.dispose());
    super.onClose();
  }
}
